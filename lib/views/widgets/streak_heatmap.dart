import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';

class StreakHeatmap extends StatelessWidget {
  final Map<String, double> heatmapData; // YYYY-MM-DD -> rate (0.0 to 1.0)
  final Function(String date, double rate)? onDayTap;

  const StreakHeatmap({
    super.key,
    required this.heatmapData,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dates = heatmapData.keys.toList();
    if (dates.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '30-Day Activity Matrix',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Less',
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                ),
                const SizedBox(width: 3),
                _buildIntensityLegend(0.0, isDark),
                const SizedBox(width: 2),
                _buildIntensityLegend(0.33, isDark),
                const SizedBox(width: 2),
                _buildIntensityLegend(0.66, isDark),
                const SizedBox(width: 2),
                _buildIntensityLegend(1.0, isDark),
                const SizedBox(width: 3),
                Text(
                  'More',
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate exact item size for 6 columns grid so it never overflows
            final availableWidth = constraints.maxWidth;
            const columns = 6;
            const spacing = 6.0;
            final itemWidth = ((availableWidth - (spacing * (columns - 1))) / columns).floorToDouble();

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: dates.map((dateStr) {
                final rate = heatmapData[dateStr] ?? 0.0;
                final date = DateTime.tryParse(dateStr) ?? DateTime.now();
                final dayFormatted = DateFormat('MMM d').format(date);

                return Tooltip(
                  message: '$dayFormatted: ${(rate * 100).toInt()}% completed',
                  child: GestureDetector(
                    onTap: () => onDayTap?.call(dateStr, rate),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: itemWidth,
                      height: itemWidth,
                      decoration: BoxDecoration(
                        color: _getColorForRate(rate, isDark),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0x33FFFFFF)
                              : const Color(0x1F000000),
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: rate > 0.5
                                ? Colors.white
                                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildIntensityLegend(double rate, bool isDark) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: _getColorForRate(rate, isDark),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Color _getColorForRate(double rate, bool isDark) {
    if (rate <= 0.0) {
      return isDark ? const Color(0xFF242836) : const Color(0xFFE2E8F0);
    } else if (rate < 0.35) {
      return AppColors.primary.withValues(alpha: 0.35);
    } else if (rate < 0.70) {
      return AppColors.primary.withValues(alpha: 0.65);
    } else {
      return AppColors.primary;
    }
  }
}
