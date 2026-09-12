import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../models/habit_category.dart';
import '../../models/milestone_badge.dart';
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

          // 2. 30-Day Heatmap Card (wrapped in RepaintBoundary for 60/120fps scrolling)
          BounceCard(
            padding: const EdgeInsets.all(20),
            child: RepaintBoundary(
              child: StreakHeatmap(
                heatmapData: heatmapData,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 3. Streak Milestones & Trophies
          _buildMilestonesCard(context, isDark, habitProvider),
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

  Widget _buildMilestonesCard(BuildContext context, bool isDark, HabitProvider provider) {
    final theme = Theme.of(context);
    final totalCompletions = provider.overallTotalCompletions;
    final bestStreak = provider.overallBestStreak;
    final badges = MilestoneBadge.allBadges;

    final unlockedCount = badges.where((b) => b.checkUnlocked(totalCompletions, bestStreak)).length;

    return BounceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Streak Milestones & Trophies',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unlockedCount / ${badges.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: badges.map((badge) {
              final isUnlocked = badge.checkUnlocked(totalCompletions, bestStreak);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? badge.color.withValues(alpha: isDark ? 0.15 : 0.08)
                        : (isDark ? const Color(0xFF161924) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isUnlocked
                          ? badge.color.withValues(alpha: 0.4)
                          : (isDark ? const Color(0xFF252B3C) : const Color(0xFFE2E8F0)),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? badge.color.withValues(alpha: 0.25)
                              : (isDark ? const Color(0xFF222736) : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          badge.icon,
                          size: 18,
                          color: isUnlocked
                              ? badge.color
                              : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              badge.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isUnlocked
                                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                    : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              badge.requirement,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isUnlocked)
                        const Icon(CupertinoIcons.checkmark_circle_fill, color: AppColors.success, size: 18)
                      else
                        const Icon(CupertinoIcons.lock_fill, color: Color(0xFF64748B), size: 14),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
