import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../models/habit_category.dart';
import '../../providers/habit_provider.dart';
import '../widgets/bounce_card.dart';
import '../widgets/frosted_app_bar.dart';
import '../widgets/streak_heatmap.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habitProvider = Provider.of<HabitProvider>(context);

    final heatmapData = habitProvider.get30DayHeatmapData();
    final weeklyTrend = habitProvider.getWeeklyTrend();
    final categoryDist = habitProvider.getCategoryDistribution();
    final habits = habitProvider.habits;

    return Scaffold(
      appBar: FrostedAppBar(
        title: Text(
          'Analytics & Streaks',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
        children: [
          // 1. Overall Lifetime KPI Metrics
          Row(
            children: [
              Expanded(
                child: BounceCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(CupertinoIcons.checkmark_seal_fill, color: AppColors.success, size: 16),
                          const SizedBox(width: 6),
                          Text('Check-ins', style: theme.textTheme.labelSmall),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${habitProvider.overallTotalCompletions}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                      Text('Lifetime logged', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BounceCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(CupertinoIcons.flame_fill, color: Color(0xFFFF6B4A), size: 16),
                          const SizedBox(width: 6),
                          Text('Best Streak', style: theme.textTheme.labelSmall),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${habitProvider.overallBestStreak} Days',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFF6B4A),
                        ),
                      ),
                      Text('Top consistency', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2. 30-Day Heatmap Card
          BounceCard(
            padding: const EdgeInsets.all(20),
            child: StreakHeatmap(
              heatmapData: heatmapData,
            ),
          ),
          const SizedBox(height: 18),

          // 3. Weekly 7-Day Completion Trend Bar Chart
          BounceCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Past 7 Days Performance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: weeklyTrend.map((item) {
                    final barHeight = (item.rate * 110).clamp(6.0, 110.0);
                    final isFull = item.rate >= 1.0;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${(item.rate * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 28,
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isFull
                                  ? [AppColors.success, const Color(0xFF34D399)]
                                  : [AppColors.primary, AppColors.accent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: item.rate > 0.3
                                ? [
                                    BoxShadow(
                                      color: (isFull ? AppColors.success : AppColors.primary)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.dayLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 4. Category Breakdown
          BounceCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Habits by Category',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                if (categoryDist.isEmpty)
                  Text('No habits created yet.', style: theme.textTheme.bodyMedium)
                else
                  ...categoryDist.entries.map((entry) {
                    final catInfo = HabitCategory.getByName(entry.key);
                    final count = entry.value;
                    final total = habits.length;
                    final ratio = total > 0 ? count / total : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(catInfo.icon, size: 15, color: catInfo.color),
                                  const SizedBox(width: 8),
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '$count habits (${(ratio * 100).toInt()}%)',
                                style: theme.textTheme.labelSmall?.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 7,
                              backgroundColor: isDark ? const Color(0xFF242836) : const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(catInfo.color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 5. Routine Consistency Leaderboard
          BounceCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Routine Leaderboard',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (habits.isEmpty)
                  Text('No routines created yet.', style: theme.textTheme.bodyMedium)
                else
                  ...habits.map((h) {
                    final stats = habitProvider.getStats(h.id!);
                    final color = h.colorValue;
                    final icon = AppIcons.getIcon(h.icon);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, color: color, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                Text(
                                  '${stats.totalCompleted} total completions',
                                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B4A).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(CupertinoIcons.flame_fill, color: Color(0xFFFF6B4A), size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  '${stats.longestStreak}d',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFF6B4A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
