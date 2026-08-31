import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../models/habit.dart';
import 'bounce_button.dart';
import 'bounce_card.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final bool isRestDay;
  final int streak;
  final VoidCallback onToggle;
  final VoidCallback? onToggleRestDay;
  final VoidCallback onTap;

  const HabitTile({
    super.key,
    required this.habit,
    required this.isCompleted,
    this.isRestDay = false,
    required this.streak,
    required this.onToggle,
    this.onToggleRestDay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habitColor = habit.colorValue;
    final habitIcon = AppIcons.getIcon(habit.icon);

    return Dismissible(
      key: ValueKey('habit_${habit.id}_${isCompleted}_$isRestDay'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe Right: Quick Check-in Toggle
          onToggle();
        } else if (direction == DismissDirection.endToStart) {
          // Swipe Left: Rest Day Toggle
          if (onToggleRestDay != null) {
            onToggleRestDay!();
          }
        }
        return false; // Do not remove widget from list tree
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFF64748B) : AppColors.success,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(
              isCompleted ? CupertinoIcons.arrow_uturn_left : CupertinoIcons.checkmark_alt_circle_fill,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              isCompleted ? 'Undo' : 'Done',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              isRestDay ? 'Remove Rest' : 'Rest Day',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.pause_circle_fill,
              color: Colors.white,
              size: 22,
            ),
          ],
        ),
      ),
      child: BounceCard(
        onTap: onTap,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        color: isCompleted
            ? habitColor.withValues(alpha: isDark ? 0.15 : 0.08)
            : (isRestDay ? const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.15 : 0.08) : null),
        border: isCompleted
            ? Border.all(
                color: habitColor.withValues(alpha: isDark ? 0.4 : 0.3),
                width: 1.5,
              )
            : (isRestDay
                ? Border.all(
                    color: const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.4 : 0.3),
                    width: 1.5,
                  )
                : null),
        child: Row(
          children: [
            // 1. Icon Container
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isCompleted
                    ? habitColor.withValues(alpha: 0.25)
                    : (isRestDay
                        ? const Color(0xFF3B82F6).withValues(alpha: 0.25)
                        : habitColor.withValues(alpha: isDark ? 0.2 : 0.12)),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                habitIcon,
                color: isRestDay ? const Color(0xFF3B82F6) : habitColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // 2. Habit Title & Category Metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    habit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                      color: isCompleted
                          ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 2,
                    children: [
                      // Category Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF242836) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          habit.category,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Rest Day Badge or Frequency
                      if (isRestDay)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Rest Day',
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        Text(
                          habit.frequency,
                          style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                        ),

                      // Streak Badge
                      if (streak > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.flame_fill,
                              color: Color(0xFFFF6B4A),
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '$streak',
                              style: const TextStyle(
                                color: Color(0xFFFF6B4A),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // 3. One-Tap Bounce Completion Checkbox
            BounceButton(
              onTap: onToggle,
              playSound: false,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? habitColor
                      : (isRestDay ? const Color(0xFF3B82F6) : Colors.transparent),
                  border: Border.all(
                    color: isCompleted
                        ? habitColor
                        : (isRestDay
                            ? const Color(0xFF3B82F6)
                            : (isDark ? const Color(0xFF3F465E) : const Color(0xFFCBD5E1))),
                    width: 2.0,
                  ),
                  boxShadow: (isCompleted || isRestDay)
                      ? [
                          BoxShadow(
                            color: (isCompleted ? habitColor : const Color(0xFF3B82F6)).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: isCompleted
                    ? const Icon(
                        CupertinoIcons.checkmark,
                        color: Colors.white,
                        size: 18,
                      )
                    : (isRestDay
                        ? const Icon(
                            CupertinoIcons.pause_fill,
                            color: Colors.white,
                            size: 16,
                          )
                        : null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
