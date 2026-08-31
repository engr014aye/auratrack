import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/daily_reflection.dart';

class ReflectionRepository {
  final DatabaseHelper _dbHelper;

  ReflectionRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<DailyReflection?> getReflectionForDate(String dateString) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'daily_reflections',
        where: 'date = ?',
        whereArgs: [dateString],
        limit: 1,
      );
      if (result.isEmpty) return null;
      return DailyReflection.fromMap(result.first);
    } catch (e) {
      return null;
    }
  }

  Future<List<DailyReflection>> getAllReflections() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'daily_reflections',
        orderBy: 'date DESC',
      );
      return result.map((m) => DailyReflection.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveReflection(DailyReflection reflection) async {
    final db = await _dbHelper.database;
    await db.insert(
      'daily_reflections',
      reflection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteReflection(String dateString) async {
    final db = await _dbHelper.database;
    await db.delete(
      'daily_reflections',
      where: 'date = ?',
      whereArgs: [dateString],
    );
  }
}
