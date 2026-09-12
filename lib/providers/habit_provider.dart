import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../core/services/sound_service.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../repositories/habit_repository.dart';

class HabitProvider extends ChangeNotifier {
  final HabitRepository _repository;

  HabitProvider({HabitRepository? repository})
      : _repository = repository ?? HabitRepository();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'All';
  String _statusFilter = 'All'; // 'All', 'Pending', 'Done'
  List<Habit> _habits = [];
  Map<int, bool> _completionMap = {};
  Map<int, bool> _restDayMap = {};
  Map<int, ({int currentStreak, int longestStreak, int totalCompleted})> _statsMap = {};
  List<HabitLog> _allLogs = [];
  bool _isLoading = false;
  bool _showCelebration = false;

  // Getters
  DateTime get selectedDate => _selectedDate;
  String get selectedCategory => _selectedCategory;
  String get statusFilter => _statusFilter;
  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  bool get showCelebration => _showCelebration;
  List<HabitLog> get allLogs => _allLogs;
  int get totalLifetimeLogs => _allLogs.where((l) => !l.isRestDay).length;

  String get selectedDateFormatted => DateFormat('yyyy-MM-dd').format(_selectedDate);
  bool get isSelectedDateToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  /// Returns habits that are scheduled for the currently selected date & filtered by category/status.
  List<Habit> get filteredHabits {
    var list = _habits.where((h) => h.isScheduledForDate(_selectedDate)).toList();
    if (_selectedCategory != 'All') {
      list = list.where((h) => h.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }
    if (_statusFilter == 'Pending') {
      list = list.where((h) => !isCompleted(h.id!) && !isRestDay(h.id!)).toList();
    } else if (_statusFilter == 'Done') {
      list = list.where((h) => isCompleted(h.id!) || isRestDay(h.id!)).toList();
    }
    return list;
  }

  bool isCompleted(int habitId) => _completionMap[habitId] ?? false;
  bool isRestDay(int habitId) => _restDayMap[habitId] ?? false;

  ({int currentStreak, int longestStreak, int totalCompleted}) getStats(int habitId) {
    return _statsMap[habitId] ?? (currentStreak: 0, longestStreak: 0, totalCompleted: 0);
  }

  int get totalScheduledToday => _habits.where((h) => h.isScheduledForDate(_selectedDate)).length;
  int get totalCount => totalScheduledToday;

  int get completedScheduledToday {
    final scheduled = _habits.where((h) => h.isScheduledForDate(_selectedDate)).toList();
    if (scheduled.isEmpty) return 0;
    return scheduled.where((h) => isCompleted(h.id!) || isRestDay(h.id!)).length;
  }
  int get completedCount => completedScheduledToday;

  double get completionProgress {
    if (totalScheduledToday == 0) return 0.0;
    return completedScheduledToday / totalScheduledToday;
  }

  /// Calculates completion progress for the date strip indicator
  double getProgressForDate(DateTime date) {
    final scheduled = _habits.where((h) => h.isScheduledForDate(date)).toList();
    if (scheduled.isEmpty) return 0.0;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final logsForDate = _allLogs.where((l) => l.completedDate == dateStr).toList();
    int count = 0;
    for (final h in scheduled) {
      if (logsForDate.any((l) => l.habitId == h.id)) {
        count++;
      }
    }
    return count / scheduled.length;
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    SoundService().playClick();
    notifyListeners();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    await refreshData();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setSelectedDate(DateTime date) async {
    _selectedDate = date;
    await _loadCompletionsForSelectedDate();
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    SoundService().playClick();
    notifyListeners();
  }

  void dismissCelebration() {
    _showCelebration = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    _habits = await _repository.getHabits(includeArchived: false);
    _allLogs = await _repository.getAllLogs();
    await _loadCompletionsForSelectedDate();
    await _loadAllStats();
    notifyListeners();
  }

  Future<void> _loadCompletionsForSelectedDate() async {
    final dateStr = selectedDateFormatted;
    final logs = await _repository.getLogsForDate(dateStr);
    
    final completedMap = <int, bool>{};
    final restMap = <int, bool>{};

    for (final log in logs) {
      if (log.isRestDay) {
        restMap[log.habitId] = true;
        completedMap[log.habitId] = false;
      } else {
        completedMap[log.habitId] = true;
        restMap[log.habitId] = false;
      }
    }

    _completionMap = {
      for (final h in _habits)
        if (h.id != null) h.id!: completedMap[h.id!] ?? false,
    };
    _restDayMap = {
      for (final h in _habits)
        if (h.id != null) h.id!: restMap[h.id!] ?? false,
    };
  }

  Future<void> _loadAllStats() async {
    final stats = <int, ({int currentStreak, int longestStreak, int totalCompleted})>{};
    for (final h in _habits) {
      if (h.id != null) {
        stats[h.id!] = await _repository.getHabitStats(h.id!);
      }
    }
    _statsMap = stats;
  }

  Future<void> toggleHabitCompletion(int habitId, {String? note}) async {
    final dateStr = selectedDateFormatted;
    final isNowCompleted = await _repository.toggleCompletion(habitId, dateStr, note: note);
    _completionMap[habitId] = isNowCompleted;
    if (isNowCompleted) _restDayMap[habitId] = false;

    // Refresh logs & stats
    _allLogs = await _repository.getAllLogs();
    if (_habits.any((h) => h.id == habitId)) {
      _statsMap[habitId] = await _repository.getHabitStats(habitId);
    }

    if (isNowCompleted) {
      // If all completed today, trigger celebration
      if (completedScheduledToday == totalScheduledToday && totalScheduledToday > 0) {
        SoundService().playCelebration();
        _showCelebration = true;
      } else {
        SoundService().playChime();
      }
    } else {
      SoundService().playPop();
    }

    notifyListeners();
  }

  Future<void> toggleRestDay(int habitId) async {
    final dateStr = selectedDateFormatted;
    final isNowRest = await _repository.toggleRestDay(habitId, dateStr);
    _restDayMap[habitId] = isNowRest;
    if (isNowRest) _completionMap[habitId] = false;

    _allLogs = await _repository.getAllLogs();
    if (_habits.any((h) => h.id == habitId)) {
      _statsMap[habitId] = await _repository.getHabitStats(habitId);
    }
    SoundService().playPop();
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    await _repository.insertHabit(habit);
    SoundService().playPop();
    await refreshData();
  }

  Future<void> updateHabit(Habit habit) async {
    await _repository.updateHabit(habit);
    SoundService().playClick();
    await refreshData();
  }

  Future<void> deleteHabit(int habitId) async {
    await _repository.deleteHabit(habitId);
    SoundService().playPop();
    await refreshData();
  }

  Future<void> archiveHabit(int habitId, bool isArchived) async {
    await _repository.setArchived(habitId, isArchived);
    await refreshData();
  }

  // --- Analytics Helpers ---

  Map<String, int> getCategoryDistribution() {
    final dist = <String, int>{};
    for (final h in _habits) {
      dist[h.category] = (dist[h.category] ?? 0) + 1;
    }
    return dist;
  }

  Map<String, double> get30DayHeatmapData() {
    final map = <String, double>{};
    final now = DateTime.now();
    final totalHabits = _habits.length;

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final logsForDate = _allLogs.where((l) => l.completedDate == dateStr).length;

      if (totalHabits == 0) {
        map[dateStr] = 0.0;
      } else {
        map[dateStr] = (logsForDate / totalHabits).clamp(0.0, 1.0);
      }
    }
    return map;
  }

  List<({String dayLabel, double rate, int completed, int total})> getWeeklyTrend() {
    final list = <({String dayLabel, double rate, int completed, int total})>[];
    final now = DateTime.now();
    final totalHabits = _habits.length;

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final dayLabel = DateFormat('E').format(date);
      final completed = _allLogs.where((l) => l.completedDate == dateStr).length;
      final rate = totalHabits > 0 ? (completed / totalHabits).clamp(0.0, 1.0) : 0.0;

      list.add((
        dayLabel: dayLabel,
        rate: rate,
        completed: completed,
        total: totalHabits,
      ));
    }
    return list;
  }

  int get overallTotalCompletions => _allLogs.where((l) => !l.isRestDay).length;

  int get overallBestStreak {
    int maxStreak = 0;
    for (final stats in _statsMap.values) {
      if (stats.longestStreak > maxStreak) {
        maxStreak = stats.longestStreak;
      }
    }
    return maxStreak;
  }
}
