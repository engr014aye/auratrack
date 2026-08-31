import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class DailyReflection {
  final String date; // YYYY-MM-DD
  final String mood; // Radiant, Good, Neutral, Low, Stressed
  final String? note;
  final DateTime updatedAt;

  DailyReflection({
    required this.date,
    required this.mood,
    this.note,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Color get moodColor {
    switch (mood) {
      case 'Radiant':
      case 'Rad':
        return AppColors.moodRad;
      case 'Good':
        return AppColors.moodGood;
      case 'Neutral':
      case 'Meh':
        return AppColors.moodMeh;
      case 'Low':
      case 'Down':
        return AppColors.moodDown;
      case 'Stressed':
        return AppColors.moodStressed;
      default:
        return AppColors.primary;
    }
  }

  String get moodEmoji {
    switch (mood) {
      case 'Radiant':
      case 'Rad':
        return '⚡';
      case 'Good':
        return '✨';
      case 'Neutral':
      case 'Meh':
        return '☕';
      case 'Low':
      case 'Down':
        return '🌧️';
      case 'Stressed':
        return '🔥';
      default:
        return '🌟';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'mood': mood,
      'note': note,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DailyReflection.fromMap(Map<String, dynamic> map) {
    return DailyReflection(
      date: map['date'] as String,
      mood: map['mood'] as String? ?? 'Good',
      note: map['note'] as String?,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
