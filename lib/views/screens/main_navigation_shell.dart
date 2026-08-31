import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/sound_service.dart';
import '../widgets/bounce_button.dart';
import 'analytics_screen.dart';
import 'dashboard_screen.dart';
import 'reflections_screen.dart';
import 'settings_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    AnalyticsScreen(),
    ReflectionsScreen(),
    SettingsScreen(),
  ];

  final List<({String label, IconData icon, IconData activeIcon})> _tabs = const [
    (
      label: AppStrings.navToday,
      icon: CupertinoIcons.sun_max,
      activeIcon: CupertinoIcons.sun_max_fill,
    ),
    (
      label: AppStrings.navAnalytics,
      icon: CupertinoIcons.chart_bar_alt_fill,
      activeIcon: CupertinoIcons.chart_bar_square_fill,
    ),
    (
      label: AppStrings.navReflections,
      icon: CupertinoIcons.book,
      activeIcon: CupertinoIcons.book_fill,
    ),
    (
      label: AppStrings.navSettings,
      icon: CupertinoIcons.gear_alt,
      activeIcon: CupertinoIcons.gear_alt_fill,
    ),
  ];

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    SoundService().playClick();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final navBg = isDark
        ? const Color(0xD90F1117)
        : const Color(0xD9FFFFFF);

    final borderColor = isDark
        ? const Color(0x29FFFFFF)
        : const Color(0x1F000000);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 70 + MediaQuery.of(context).padding.bottom,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 6,
              top: 8,
            ),
            decoration: BoxDecoration(
              color: navBg,
              border: Border(
                top: BorderSide(color: borderColor, width: 0.8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isSelected = _currentIndex == index;

                return Expanded(
                  child: BounceButton(
                    onTap: () => _onTabSelected(index),
                    playSound: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            isSelected ? tab.activeIcon : tab.icon,
                            size: 22,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
