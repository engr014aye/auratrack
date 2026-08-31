import 'package:flutter/cupertino.dart';

/// Central icon definitions for habits, categories, and navigation.
class AppIcons {
  AppIcons._();

  // Category Icons
  static const IconData categoryMorning = CupertinoIcons.sun_max_fill;
  static const IconData categoryAfternoon = CupertinoIcons.sun_haze_fill;
  static const IconData categoryEvening = CupertinoIcons.moon_stars_fill;
  static const IconData categoryHealth = CupertinoIcons.heart_fill;
  static const IconData categoryMind = CupertinoIcons.sparkles;
  static const IconData categoryProductivity = CupertinoIcons.flame_fill;

  // Habit Icon Selection Map
  static const Map<String, IconData> habitIconMap = {
    'flame': CupertinoIcons.flame_fill,
    'heart': CupertinoIcons.heart_fill,
    'sun': CupertinoIcons.sun_max_fill,
    'moon': CupertinoIcons.moon_stars_fill,
    'sparkles': CupertinoIcons.sparkles,
    'book': CupertinoIcons.book_fill,
    'drop': CupertinoIcons.drop_fill,
    'bolt': CupertinoIcons.bolt_fill,
    'leaf': CupertinoIcons.leaf_arrow_circlepath,
    'bed': CupertinoIcons.bed_double_fill,
    'timer': CupertinoIcons.timer,
    'sportscourt': CupertinoIcons.sportscourt_fill,
    'music': CupertinoIcons.music_note_2,
    'pencil': CupertinoIcons.pencil_ellipsis_rectangle,
    'briefcase': CupertinoIcons.briefcase_fill,
    'cart': CupertinoIcons.cart_fill,
    'checkmark': CupertinoIcons.checkmark_seal_fill,
    'star': CupertinoIcons.star_fill,
    'gift': CupertinoIcons.gift_fill,
    'compass': CupertinoIcons.compass_fill,
    'bell': CupertinoIcons.bell_fill,
    'paintbrush': CupertinoIcons.paintbrush_fill,
  };

  static IconData getIcon(String key, {IconData fallback = CupertinoIcons.star_fill}) {
    return habitIconMap[key] ?? fallback;
  }

  static String getIconKey(IconData icon) {
    for (final entry in habitIconMap.entries) {
      if (entry.value == icon) return entry.key;
    }
    return 'star';
  }
}
