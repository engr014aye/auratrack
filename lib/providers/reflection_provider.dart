import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../core/services/sound_service.dart';
import '../models/daily_reflection.dart';
import '../repositories/reflection_repository.dart';

class ReflectionProvider extends ChangeNotifier {
  final ReflectionRepository _repository;

  ReflectionProvider({ReflectionRepository? repository})
      : _repository = repository ?? ReflectionRepository();

  DailyReflection? _currentReflection;
  List<DailyReflection> _history = [];
  bool _isLoading = false;

  DailyReflection? get currentReflection => _currentReflection;
  List<DailyReflection> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> loadForDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    _currentReflection = await _repository.getReflectionForDate(dateStr);
    _history = await _repository.getAllReflections();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveReflection({
    required DateTime date,
    required String mood,
    String? note,
  }) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final reflection = DailyReflection(
      date: dateStr,
      mood: mood,
      note: note,
      updatedAt: DateTime.now(),
    );

    await _repository.saveReflection(reflection);
    SoundService().playChime();
    _currentReflection = reflection;
    _history = await _repository.getAllReflections();
    notifyListeners();
  }

  Future<void> deleteReflection(String dateStr) async {
    await _repository.deleteReflection(dateStr);
    SoundService().playPop();
    _currentReflection = null;
    _history = await _repository.getAllReflections();
    notifyListeners();
  }
}
