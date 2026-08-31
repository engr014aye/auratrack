import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class Habit {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final String category;
  final String frequency;
  final int targetDays;
  final List<int> scheduledDays; // 1 = Mon ... 7 = Sun
  final DateTime createdAt;
  final bool isArchived;

  Habit({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.category,
    this.frequency = 'Daily',
    this.targetDays = 1,
    List<int>? scheduledDays,
    DateTime? createdAt,
    this.isArchived = false,
  })  : scheduledDays = scheduledDays ?? const [1, 2, 3, 4, 5, 6, 7],
        createdAt = createdAt ?? DateTime.now();

  Color get colorValue => AppColors.fromHex(color);

  /// Checks if this habit is scheduled for the given date (weekday 1=Mon .. 7=Sun)
  bool isScheduledForDate(DateTime date) {
    if (frequency == 'Daily') return true;
    if (frequency == 'Weekdays') return date.weekday >= 1 && date.weekday <= 5;
    if (frequency == 'Weekends') return date.weekday == 6 || date.weekday == 7;
    return scheduledDays.contains(date.weekday);
  }

  Habit copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    String? category,
    String? frequency,
    int? targetDays,
    List<int>? scheduledDays,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      targetDays: targetDays ?? this.targetDays,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'category': category,
      'frequency': frequency,
      'target_days': targetDays,
      'scheduled_days': scheduledDays.join(','),
      'created_at': createdAt.toIso8601String(),
      'is_archived': isArchived ? 1 : 0,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    List<int> parsedDays = const [1, 2, 3, 4, 5, 6, 7];
    if (map['scheduled_days'] != null && (map['scheduled_days'] as String).isNotEmpty) {
      parsedDays = (map['scheduled_days'] as String)
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .whereType<int>()
          .toList();
      if (parsedDays.isEmpty) parsedDays = const [1, 2, 3, 4, 5, 6, 7];
    }

    return Habit(
      id: map['id'] as int?,
      name: map['name'] as String? ?? 'Untitled Habit',
      icon: map['icon'] as String? ?? 'star',
      color: map['color'] as String? ?? '#6366F1',
      category: map['category'] as String? ?? 'Morning',
      frequency: map['frequency'] as String? ?? 'Daily',
      targetDays: (map['target_days'] as int?) ?? 1,
      scheduledDays: parsedDays,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      isArchived: (map['is_archived'] as int? ?? 0) == 1,
    );
  }
}
