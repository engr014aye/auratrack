import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/daily_quote.dart';
import '../../models/habit_category.dart';
import '../../providers/habit_provider.dart';
import '../modals/add_edit_habit_modal.dart';
import '../widgets/activity_ring.dart';
import '../widgets/bounce_button.dart';
import '../widgets/bounce_card.dart';
import '../widgets/celebration_overlay.dart';
import '../widgets/frosted_app_bar.dart';
import '../widgets/habit_tile.dart';
import 'habit_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habitProvider = Provider.of<HabitProvider>(context);
    final filteredHabits = habitProvider.filteredHabits;

    return Stack(
      children: [
        Scaffold(
          appBar: FrostedAppBar(
            centerTitle: false,
            title: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'AuraTrack',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            actions: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onPressed: () => AddEditHabitModal.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.add, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'New',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: habitProvider.isLoading
              ? const Center(child: CupertinoActivityIndicator(radius: 16))
              : ListView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
                  children: [
                    // 1. Horizontal Date Strip with Mini Progress Indicators
                    _buildDateStrip(context, habitProvider),
                    const SizedBox(height: 18),

                    // 2. Activity Ring Hero Card
                    _buildActivityRingCard(context, habitProvider),
                    const SizedBox(height: 14),

                    // 3. Daily Inspiration Wisdom Capsule
                    _buildDailyQuoteCard(context, isDark),
                    const SizedBox(height: 18),

                    // 4. Category Filter Selector
                    _buildCategoryFilter(context, habitProvider),
                    const SizedBox(height: 8),

                    // 5. Status Filter (All / Pending / Done)
                    _buildStatusFilter(context, habitProvider),

                    // 6. Habits List
                    if (filteredHabits.isEmpty)
                      _buildEmptyState(context, isDark, habitProvider)
                    else
                      ...filteredHabits.map((habit) {
                        final isDone = habitProvider.isCompleted(habit.id!);
                        final isRest = habitProvider.isRestDay(habit.id!);
                        final stats = habitProvider.getStats(habit.id!);
                        return HabitTile(
                          key: ValueKey(habit.id),
                          habit: habit,
                          isCompleted: isDone,
                          isRestDay: isRest,
                          streak: stats.currentStreak,
                          onToggle: () => habitProvider.toggleHabitCompletion(habit.id!),
                          onToggleRestDay: () => habitProvider.toggleRestDay(habit.id!),
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => HabitDetailScreen(habit: habit),
                              ),
                            );
                          },
                        );
                      }),
                  ],
                ),
        ),

        // Celebration Overlay when 100% completed
        if (habitProvider.showCelebration)
          CelebrationOverlay(
            onDismiss: () => habitProvider.dismissCelebration(),
          ),
      ],
    );
  }

  Widget _buildDateStrip(BuildContext context, HabitProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    // Show 14 days centered around selected date (7 past, today, 6 future)
    final days = List.generate(14, (i) => now.subtract(Duration(days: 7 - i)));

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day.year == provider.selectedDate.year &&
              day.month == provider.selectedDate.month &&
              day.day == provider.selectedDate.day;
          final isToday = day.year == now.year &&
              day.month == now.month &&
              day.day == now.day;
          final dayProgress = provider.getProgressForDate(day);

          return BounceButton(
            onTap: () => provider.setSelectedDate(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? const Color(0xFF1E2230) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isToday && !isSelected
                      ? AppColors.primary
                      : (isSelected
                          ? AppColors.primary
                          : (isDark ? const Color(0xFF2D3348) : const Color(0xFFE2E8F0))),
                  width: isToday && !isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(day).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Mini Progress Indicator
                  Container(
                    width: dayProgress > 0 ? 14 : 4,
                    height: 3,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : (dayProgress >= 1.0
                              ? const Color(0xFF10B981)
                              : (dayProgress > 0
                                  ? AppColors.primary
                                  : (isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1)))),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityRingCard(BuildContext context, HabitProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = provider.completionProgress;
    final percent = (progress * 100).toInt();

    String headline = 'Make it happen!';
    if (percent == 100) {
      headline = 'All Done! Outstanding 🎉';
    } else if (percent >= 50) {
      headline = 'Great Momentum! 🔥';
    } else if (percent > 0) {
      headline = 'Good Start! ✨';
    }

    return BounceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: isDark ? const Color(0xFF191D29) : Colors.white,
      child: Row(
        children: [
          // Activity Ring wrapped in RepaintBoundary for optimal 60/120fps performance
          RepaintBoundary(
            child: ActivityRing(
              progress: progress,
              size: 84,
              strokeWidth: 9,
              gradientColors: const [Color(0xFF6366F1), Color(0xFFEC4899)],
              centerChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    'DONE',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Overview Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.completedCount} of ${provider.totalCount} routines completed.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.flame_fill, color: Color(0xFFFF6B4A), size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'Best Streak: ${provider.overallBestStreak} Days',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF6B4A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuoteCard(BuildContext context, bool isDark) {
    final quote = DailyQuote.today();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161924) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF242B3D) : const Color(0xFFE2E8F0),
          width: 0.9,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(CupertinoIcons.quote_bubble_fill, size: 13, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${quote.text}"',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.35,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '— ${quote.author}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, HabitProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = HabitCategory.defaultCategories;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = provider.selectedCategory.toLowerCase() == cat.name.toLowerCase();

          return BounceButton(
            onTap: () => provider.setSelectedCategory(cat.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? cat.color
                    : (isDark ? const Color(0xFF1E2230) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: cat.color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    cat.icon,
                    size: 13,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context, HabitProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final options = ['All', 'Pending', 'Done'];

    return Padding(
      padding: const EdgeInsets.only(left: 2, top: 4, bottom: 8),
      child: Row(
        children: options.map((opt) {
          final isSelected = provider.statusFilter == opt;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: BounceButton(
              onTap: () => provider.setStatusFilter(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF2D3348) : const Color(0xFFE2E8F0))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                        : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, HabitProvider provider) {
    final theme = Theme.of(context);
    final isFilterActive = provider.selectedCategory != 'All' || provider.statusFilter != 'All';

    return Container(
      padding: const EdgeInsets.all(36),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            isFilterActive ? CupertinoIcons.line_horizontal_3_decrease : CupertinoIcons.sparkles,
            size: 54,
            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            isFilterActive ? 'No Matching Routines' : 'Start Your Routine',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isFilterActive
                ? 'No habits match your active filter. Try switching back to "All".'
                : 'Tap "+ New" above to add your first habit or choose from starter packs!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
