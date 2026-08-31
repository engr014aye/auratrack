class HabitLog {
  final int? id;
  final int habitId;
  final String completedDate; // Format: YYYY-MM-DD
  final String? note;
  final bool isRestDay;

  HabitLog({
    this.id,
    required this.habitId,
    required this.completedDate,
    this.note,
    this.isRestDay = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'completed_date': completedDate,
      'note': note,
      'is_rest_day': isRestDay ? 1 : 0,
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'] as int?,
      habitId: map['habit_id'] as int,
      completedDate: map['completed_date'] as String,
      note: map['note'] as String?,
      isRestDay: (map['is_rest_day'] as int? ?? 0) == 1,
    );
  }
}
