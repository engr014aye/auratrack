import 'package:intl/intl.dart';
import '../core/database/database_helper.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

class HabitRepository {
  final DatabaseHelper _dbHelper;

  HabitRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<Habit>> getHabits({bool includeArchived = false}) async {
    try {
      final db = await _dbHelper.database;
      final whereClause = includeArchived ? null : 'is_archived = 0';
      final result = await db.query(
        'habits',
        where: whereClause,
        orderBy: 'id ASC',
      );
      return result.map((m) => Habit.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Habit?> getHabitById(int id) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'habits',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (result.isEmpty) return null;
      return Habit.fromMap(result.first);
    } catch (e) {
      return null;
    }
  }

  Future<int> insertHabit(Habit habit) async {
    final db = await _dbHelper.database;
    return await db.insert('habits', habit.toMap());
  }

  Future<int> updateHabit(Habit habit) async {
    if (habit.id == null) return 0;
    final db = await _dbHelper.database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> setArchived(int id, bool isArchived) async {
    final db = await _dbHelper.database;
    return await db.update(
      'habits',
      {'is_archived': isArchived ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Habit Logs & Completion ---

  Future<bool> toggleCompletion(int habitId, String dateString, {String? note}) async {
    final db = await _dbHelper.database;
    final existing = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND completed_date = ?',
      whereArgs: [habitId, dateString],
    );

    if (existing.isNotEmpty) {
      final wasRest = (existing.first['is_rest_day'] as int? ?? 0) == 1;
      if (wasRest) {
        // If it was a rest day, turn it into completed check-in
        await db.update(
          'habit_logs',
          {'is_rest_day': 0, 'note': note},
          where: 'habit_id = ? AND completed_date = ?',
          whereArgs: [habitId, dateString],
        );
        return true;
      } else {
        await db.delete(
          'habit_logs',
          where: 'habit_id = ? AND completed_date = ?',
          whereArgs: [habitId, dateString],
        );
        return false; // Now incomplete
      }
    } else {
      await db.insert('habit_logs', {
        'habit_id': habitId,
        'completed_date': dateString,
        'note': note,
        'is_rest_day': 0,
      });
      return true; // Now completed
    }
  }

  Future<bool> toggleRestDay(int habitId, String dateString) async {
    final db = await _dbHelper.database;
    final existing = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND completed_date = ?',
      whereArgs: [habitId, dateString],
    );

    if (existing.isNotEmpty) {
      final wasRest = (existing.first['is_rest_day'] as int? ?? 0) == 1;
      if (wasRest) {
        // Remove rest day
        await db.delete(
          'habit_logs',
          where: 'habit_id = ? AND completed_date = ?',
          whereArgs: [habitId, dateString],
        );
        return false;
      } else {
        // Change completed to rest day
        await db.update(
          'habit_logs',
          {'is_rest_day': 1},
          where: 'habit_id = ? AND completed_date = ?',
          whereArgs: [habitId, dateString],
        );
        return true;
      }
    } else {
      await db.insert('habit_logs', {
        'habit_id': habitId,
        'completed_date': dateString,
        'is_rest_day': 1,
      });
      return true;
    }
  }

  Future<bool> isCompletedOnDate(int habitId, String dateString) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'habit_logs',
        where: 'habit_id = ? AND completed_date = ? AND is_rest_day = 0',
        whereArgs: [habitId, dateString],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<HabitLog>> getLogsForDate(String dateString) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'habit_logs',
        where: 'completed_date = ?',
        whereArgs: [dateString],
      );
      return result.map((m) => HabitLog.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<HabitLog>> getLogsForHabit(int habitId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'habit_logs',
        where: 'habit_id = ?',
        whereArgs: [habitId],
        orderBy: 'completed_date DESC',
      );
      return result.map((m) => HabitLog.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<HabitLog>> getAllLogs() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query('habit_logs', orderBy: 'completed_date DESC');
      return result.map((m) => HabitLog.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Calculates current streak and longest streak in days for a habit.
  /// Note: Completed days and Rest Days both maintain continuous streak.
  Future<({int currentStreak, int longestStreak, int totalCompleted})> getHabitStats(int habitId) async {
    final logs = await getLogsForHabit(habitId);
    if (logs.isEmpty) {
      return (currentStreak: 0, longestStreak: 0, totalCompleted: 0);
    }

    final totalCompleted = logs.where((l) => !l.isRestDay).length;

    final dates = logs
        .map((l) => DateFormat('yyyy-MM-dd').parse(l.completedDate))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Descending

    if (dates.isEmpty) {
      return (currentStreak: 0, longestStreak: 0, totalCompleted: 0);
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    // Calculate current streak
    int currentStreak = 0;
    final latestDate = DateTime(dates.first.year, dates.first.month, dates.first.day);

    if (latestDate == todayDate || latestDate == yesterdayDate) {
      currentStreak = 1;
      DateTime checkDate = latestDate;
      for (int i = 1; i < dates.length; i++) {
        final d = DateTime(dates[i].year, dates[i].month, dates[i].day);
        if (checkDate.difference(d).inDays == 1) {
          currentStreak++;
          checkDate = d;
        } else if (checkDate.difference(d).inDays == 0) {
          continue;
        } else {
          break;
        }
      }
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 1;
    final ascendingDates = dates.reversed.toList();
    for (int i = 0; i < ascendingDates.length; i++) {
      if (i > 0) {
        final prev = ascendingDates[i - 1];
        final curr = ascendingDates[i];
        final diff = curr.difference(prev).inDays;
        if (diff == 1) {
          tempStreak++;
        } else if (diff > 1) {
          tempStreak = 1;
        }
      }
      if (tempStreak > longestStreak) {
        longestStreak = tempStreak;
      }
    }

    return (
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalCompleted: totalCompleted,
    );
  }
}
