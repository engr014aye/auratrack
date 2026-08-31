import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class BackupService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Exports all habits, habit_logs, and daily_reflections to a structured JSON string.
  Future<String> exportToJson() async {
    final db = await _dbHelper.database;
    final habits = await db.query('habits');
    final logs = await db.query('habit_logs');
    final reflections = await db.query('daily_reflections');

    final backupData = {
      'app': 'AuraTrack',
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'habits': habits,
      'habit_logs': logs,
      'daily_reflections': reflections,
    };

    return const JsonEncoder.withIndent('  ').convert(backupData);
  }

  /// Exports and triggers the system share sheet with a .json backup file.
  Future<String> exportAndShare() async {
    final jsonContent = await exportToJson();
    final tempDir = await getTemporaryDirectory();
    final fileName = 'auratrack_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(jsonContent);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json', name: fileName)],
        subject: 'AuraTrack Data Backup',
        text: 'Here is your AuraTrack backup file.',
      ),
    );

    return file.path;
  }

  /// Exports a human-readable CSV summary report of habits, check-ins, and reflections.
  Future<String> exportToCsvAndShare() async {
    final db = await _dbHelper.database;
    final habits = await db.query('habits');
    final logs = await db.query('habit_logs', orderBy: 'completed_date DESC');
    final reflections = await db.query('daily_reflections', orderBy: 'date DESC');

    final habitMap = {
      for (final h in habits) h['id'] as int: h['name'] as String,
    };

    final csv = StringBuffer();
    csv.writeln('# AuraTrack Habit & Routine Report');
    csv.writeln('# Exported on: ${DateTime.now().toIso8601String()}');
    csv.writeln('');

    // 1. Habits Table
    csv.writeln('=== HABITS & ROUTINES ===');
    csv.writeln('ID,Name,Category,Frequency,Target Days,Scheduled Days,Created Date');
    for (final h in habits) {
      csv.writeln(
        '${h['id']},"${(h['name'] as String).replaceAll('"', '""')}","${h['category']}","${h['frequency']}",${h['target_days']},"${h['scheduled_days']}","${h['created_at']}"',
      );
    }
    csv.writeln('');

    // 2. Check-in Logs Table
    csv.writeln('=== CHECK-IN HISTORY ===');
    csv.writeln('Date,Habit Name,Type,Note');
    for (final l in logs) {
      final habitName = habitMap[l['habit_id'] as int] ?? 'Unknown Habit';
      final isRest = (l['is_rest_day'] as int? ?? 0) == 1;
      final note = (l['note'] as String? ?? '').replaceAll('"', '""');
      csv.writeln(
        '"${l['completed_date']}","$habitName","${isRest ? 'Rest Day' : 'Completed'}","$note"',
      );
    }
    csv.writeln('');

    // 3. Daily Reflections Table
    csv.writeln('=== DAILY REFLECTIONS & MOODS ===');
    csv.writeln('Date,Mood,Journal Note');
    for (final r in reflections) {
      final note = (r['note'] as String? ?? '').replaceAll('"', '""');
      csv.writeln('"${r['date']}","${r['mood']}","$note"');
    }

    final tempDir = await getTemporaryDirectory();
    final fileName = 'auratrack_report_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(csv.toString());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv', name: fileName)],
        subject: 'AuraTrack CSV Summary Report',
        text: 'Here is your AuraTrack habit and routine summary CSV report.',
      ),
    );

    return file.path;
  }

  /// Restores data from JSON string. Returns number of habits and logs restored.
  Future<Map<String, int>> restoreFromJson(String jsonString) async {
    final db = await _dbHelper.database;
    final Map<String, dynamic> data = jsonDecode(jsonString);

    if (data['app'] != 'AuraTrack' || data['habits'] == null) {
      throw const FormatException('Invalid AuraTrack backup file format.');
    }

    final habitsList = (data['habits'] as List).cast<Map<String, dynamic>>();
    final logsList = (data['habit_logs'] as List? ?? []).cast<Map<String, dynamic>>();
    final reflectionsList = (data['daily_reflections'] as List? ?? []).cast<Map<String, dynamic>>();

    int habitsCount = 0;
    int logsCount = 0;
    int reflectionsCount = 0;

    await db.transaction((txn) async {
      // Clear existing records
      await txn.delete('habit_logs');
      await txn.delete('habits');
      await txn.delete('daily_reflections');

      // Insert habits
      for (final h in habitsList) {
        final habitMap = Map<String, dynamic>.from(h);
        await txn.insert('habits', habitMap, conflictAlgorithm: ConflictAlgorithm.replace);
        habitsCount++;
      }

      // Insert logs
      for (final l in logsList) {
        final logMap = Map<String, dynamic>.from(l);
        await txn.insert('habit_logs', logMap, conflictAlgorithm: ConflictAlgorithm.replace);
        logsCount++;
      }

      // Insert reflections
      for (final r in reflectionsList) {
        final refMap = Map<String, dynamic>.from(r);
        await txn.insert('daily_reflections', refMap, conflictAlgorithm: ConflictAlgorithm.replace);
        reflectionsCount++;
      }
    });

    return {
      'habits': habitsCount,
      'logs': logsCount,
      'reflections': reflectionsCount,
    };
  }
}
