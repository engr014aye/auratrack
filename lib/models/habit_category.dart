import 'package:flutter/cupertino.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_icons.dart';

class HabitCategory {
  final String name;
  final IconData icon;
  final Color color;

  const HabitCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<HabitCategory> defaultCategories = [
    HabitCategory(
      name: 'All',
      icon: CupertinoIcons.square_grid_2x2_fill,
      color: AppColors.primary,
    ),
    HabitCategory(
      name: 'Morning',
      icon: AppIcons.categoryMorning,
      color: AppColors.categoryMorning,
    ),
    HabitCategory(
      name: 'Afternoon',
      icon: AppIcons.categoryAfternoon,
      color: AppColors.categoryAfternoon,
    ),
    HabitCategory(
      name: 'Evening',
      icon: AppIcons.categoryEvening,
      color: AppColors.categoryEvening,
    ),
    HabitCategory(
      name: 'Health',
      icon: AppIcons.categoryHealth,
      color: AppColors.categoryHealth,
    ),
    HabitCategory(
      name: 'Mind',
      icon: AppIcons.categoryMind,
      color: AppColors.categoryMind,
    ),
    HabitCategory(
      name: 'Productivity',
      icon: AppIcons.categoryProductivity,
      color: AppColors.categoryProductivity,
    ),
  ];

  static HabitCategory getByName(String name) {
    return defaultCategories.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
      orElse: () => HabitCategory(
        name: name,
        icon: CupertinoIcons.tag_fill,
        color: AppColors.primary,
      ),
    );
  }
}
