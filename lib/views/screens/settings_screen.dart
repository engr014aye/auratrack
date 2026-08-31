import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/database/database_helper.dart';
import '../../core/services/launcher_service.dart';
import '../../providers/habit_provider.dart';
import '../../providers/reflection_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/bounce_card.dart';
import '../widgets/frosted_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _shareProgress(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final completed = habitProvider.completedCount;
    final total = habitProvider.totalCount;
    final streak = habitProvider.overallBestStreak;

    final message = '✨ AuraTrack Routine Update:\n'
        '• $completed of $total daily routines completed today!\n'
        '• Best Streak: $streak days 🔥\n\n'
        'Building consistent daily habits with AuraTrack.';

    SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: 'My AuraTrack Habit Progress',
      ),
    );
  }

  void _openPrivacyPolicy(BuildContext context) async {
    final success = await LauncherService.openUrl(AppStrings.privacyPolicyUrl);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open privacy policy link.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _openRateUs(BuildContext context) async {
    final success = await LauncherService.openPlayStoreRating();
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening Play Store rating page...'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _showWipeConfirmation(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final reflectionProvider = Provider.of<ReflectionProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Reset All Habits?'),
        content: const Text('This will reset your habits and check-ins back to the starter routine. This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(ctx).pop();
              await DatabaseHelper.instance.wipeAllData();
              await habitProvider.refreshData();
              await reflectionProvider.loadForDate(DateTime.now());
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('All data has been reset to starter defaults.'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: FrostedAppBar(
        title: Text(
          'Settings & Preferences',
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
          // 1. Featured "Rate Us" Card
          _buildSectionHeader(context, 'SUPPORT AURATRACK'),
          BounceCard(
            onTap: () => _openRateUs(context),
            padding: const EdgeInsets.all(16),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.35 : 0.25),
              width: 1.5,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.22 : 0.15),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    CupertinoIcons.star_fill,
                    color: Color(0xFFF59E0B),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Enjoying AuraTrack?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rate us on Google Play',
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(
                          5,
                          (i) => const Padding(
                            padding: EdgeInsets.only(right: 3),
                            child: Icon(
                              CupertinoIcons.star_fill,
                              color: Color(0xFFF59E0B),
                              size: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(CupertinoIcons.chevron_forward, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Appearance Section
          _buildSectionHeader(context, 'APPEARANCE'),
          BounceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Mode',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<ThemePreference>(
                    groupValue: themeProvider.themePreference,
                    children: const {
                      ThemePreference.system: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Text('System', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                      ThemePreference.light: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Text('Light', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                      ThemePreference.dark: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Text('Dark', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    },
                    onValueChanged: (val) {
                      if (val != null) themeProvider.setThemePreference(val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Sound & Tactile Physics
          _buildSectionHeader(context, 'FEEDBACK & AUDIO'),
          BounceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(CupertinoIcons.speaker_2_fill, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Sound Effects',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    CupertinoSwitch(
                      value: themeProvider.isSoundEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) => themeProvider.setSoundEnabled(val),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(CupertinoIcons.waveform, color: AppColors.accent, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Haptic Feedback',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    CupertinoSwitch(
                      value: themeProvider.isHapticsEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) => themeProvider.setHapticsEnabled(val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Share & Community
          _buildSectionHeader(context, 'COMMUNITY'),
          BounceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(CupertinoIcons.share_solid, color: AppColors.primary),
                  title: const Text('Share Daily Progress', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Share routine completions and streaks with friends', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(CupertinoIcons.chevron_forward, size: 16),
                  onTap: () => _shareProgress(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5. About & Legal
          _buildSectionHeader(context, 'ABOUT & LEGAL'),
          BounceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(CupertinoIcons.person_crop_circle_fill_badge_checkmark, color: AppColors.accent),
                  title: const Text('Developed by', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  trailing: const Text(
                    AppStrings.developerName,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(CupertinoIcons.doc_text_fill, color: AppColors.categoryMorning),
                  title: const Text('Privacy Policy', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Read our user privacy terms and policies', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(CupertinoIcons.chevron_forward, size: 16),
                  onTap: () => _openPrivacyPolicy(context),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(CupertinoIcons.arrow_counterclockwise, color: AppColors.danger),
                  title: const Text('Reset All Habits', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.danger)),
                  subtitle: const Text('Clear check-ins and reset to starter habits', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(CupertinoIcons.chevron_forward, size: 16),
                  onTap: () => _showWipeConfirmation(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // App Version Footer
          Center(
            child: Text(
              'AuraTrack • Version ${AppStrings.appVersion}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkTextTertiary
              : AppColors.lightTextTertiary,
        ),
      ),
    );
  }
}
