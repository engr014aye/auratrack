import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'bounce_button.dart';

class MoodSelector extends StatelessWidget {
  final String selectedMood;
  final ValueChanged<String> onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  static const List<({String label, String emoji, Color color})> moods = [
    (label: 'Radiant', emoji: '⚡', color: AppColors.moodRad),
    (label: 'Good', emoji: '✨', color: AppColors.moodGood),
    (label: 'Neutral', emoji: '☕', color: AppColors.moodMeh),
    (label: 'Low', emoji: '🌧️', color: AppColors.moodDown),
    (label: 'Stressed', emoji: '🔥', color: AppColors.moodStressed),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moods.map((item) {
        final isSelected = selectedMood.toLowerCase() == item.label.toLowerCase();

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: BounceButton(
              onTap: () => onMoodSelected(item.label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? item.color.withValues(alpha: isDark ? 0.25 : 0.15)
                      : (isDark ? const Color(0xFF1E2230) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? item.color
                        : (isDark ? const Color(0xFF2D3348) : const Color(0xFFE2E8F0)),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: item.color.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? item.color
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
