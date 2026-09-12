import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:auratrack/models/habit.dart';
import 'package:auratrack/models/habit_log.dart';
import 'package:auratrack/models/daily_reflection.dart';
import 'package:auratrack/models/habit_templates.dart';
import 'package:auratrack/models/milestone_badge.dart';
import 'package:auratrack/models/daily_quote.dart';
import 'package:auratrack/core/constants/app_colors.dart';

void main() {
  group('Habit Model Tests', () {
    test('Habit toMap and fromMap serialization works seamlessly with scheduled days', () {
      final habit = Habit(
        id: 1,
        name: 'Morning Yoga',
        icon: 'heart',
        color: '#6366F1',
        category: 'Health',
        frequency: 'Custom',
        scheduledDays: [1, 3, 5],
        targetDays: 3,
      );

      final map = habit.toMap();
      expect(map['name'], 'Morning Yoga');
      expect(map['category'], 'Health');
      expect(map['scheduled_days'], '1,3,5');

      final reconstructed = Habit.fromMap(map);
      expect(reconstructed.id, 1);
      expect(reconstructed.name, 'Morning Yoga');
      expect(reconstructed.scheduledDays, [1, 3, 5]);
      expect(reconstructed.colorValue, AppColors.fromHex('#6366F1'));

      // Test isScheduledForDate
      final monday = DateTime(2026, 8, 31); // 2026-08-31 is Monday (weekday = 1)
      final tuesday = DateTime(2026, 9, 1); // Tuesday (weekday = 2)
      expect(habit.isScheduledForDate(monday), isTrue);
      expect(habit.isScheduledForDate(tuesday), isFalse);
    });

    test('HabitLog toMap and fromMap serialization with rest day flag', () {
      final log = HabitLog(
        id: 10,
        habitId: 1,
        completedDate: '2026-08-27',
        note: 'Rest day pass',
        isRestDay: true,
      );

      final map = log.toMap();
      expect(map['habit_id'], 1);
      expect(map['completed_date'], '2026-08-27');
      expect(map['is_rest_day'], 1);

      final reconstructed = HabitLog.fromMap(map);
      expect(reconstructed.id, 10);
      expect(reconstructed.isRestDay, isTrue);
      expect(reconstructed.note, 'Rest day pass');
    });

    test('DailyReflection model serialization and mood colors', () {
      final reflection = DailyReflection(
        date: '2026-08-27',
        mood: 'Radiant',
        note: 'Had an energetic day!',
      );

      expect(reflection.moodEmoji, '⚡');
      expect(reflection.moodColor, AppColors.moodRad);

      final map = reflection.toMap();
      final reconstructed = DailyReflection.fromMap(map);
      expect(reconstructed.date, '2026-08-27');
      expect(reconstructed.mood, 'Radiant');
      expect(reconstructed.note, 'Had an energetic day!');
    });
  });

  group('New Feature Enhancements Tests', () {
    test('HabitTemplate starter packs are non-empty and well formed', () {
      expect(HabitTemplate.starterPacks.length, greaterThanOrEqualTo(5));
      for (final tpl in HabitTemplate.starterPacks) {
        expect(tpl.title.isNotEmpty, isTrue);
        expect(tpl.category.isNotEmpty, isTrue);
        expect(tpl.scheduledDays.isNotEmpty, isTrue);
      }
    });

    test('MilestoneBadge unlocks correctly based on completions and streaks', () {
      final firstSpark = MilestoneBadge.allBadges.firstWhere((b) => b.id == 'first_spark');
      final onFire = MilestoneBadge.allBadges.firstWhere((b) => b.id == 'on_fire');
      final habitMaster = MilestoneBadge.allBadges.firstWhere((b) => b.id == 'habit_master');

      expect(firstSpark.checkUnlocked(0, 0), isFalse);
      expect(firstSpark.checkUnlocked(1, 1), isTrue);

      expect(onFire.checkUnlocked(1, 2), isFalse);
      expect(onFire.checkUnlocked(5, 3), isTrue);

      expect(habitMaster.checkUnlocked(10, 6), isFalse);
      expect(habitMaster.checkUnlocked(10, 7), isTrue);
    });

    test('DailyQuote provides non-empty quote and author', () {
      final quote = DailyQuote.today();
      expect(quote.text.isNotEmpty, isTrue);
      expect(quote.author.isNotEmpty, isTrue);
    });
  });

  group('Color Utility Tests', () {
    test('AppColors fromHex and toHex work correctly', () {
      const originalColor = Color(0xFF6366F1);
      final hex = AppColors.toHex(originalColor);
      expect(hex, '#6366F1');

      final parsed = AppColors.fromHex(hex);
      expect(parsed.toARGB32(), originalColor.toARGB32());
    });
  });
}
