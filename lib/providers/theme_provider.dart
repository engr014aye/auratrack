import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/sound_service.dart';

enum ThemePreference { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  static const String _keyTheme = 'theme_preference';
  static const String _keySound = 'sound_enabled';
  static const String _keyHaptics = 'haptics_enabled';

  ThemePreference _themePreference = ThemePreference.system;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  ThemePreference get themePreference => _themePreference;
  bool get isSoundEnabled => _soundEnabled;
  bool get isHapticsEnabled => _hapticsEnabled;

  ThemeMode get themeMode {
    switch (_themePreference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_keyTheme);
    if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemePreference.values.length) {
      _themePreference = ThemePreference.values[themeIndex];
    }
    _soundEnabled = prefs.getBool(_keySound) ?? true;
    _hapticsEnabled = prefs.getBool(_keyHaptics) ?? true;

    SoundService().updateSettings(
      soundEnabled: _soundEnabled,
      hapticsEnabled: _hapticsEnabled,
    );

    notifyListeners();
  }

  Future<void> setThemePreference(ThemePreference preference) async {
    if (_themePreference == preference) return;
    _themePreference = preference;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, preference.index);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    SoundService().updateSettings(soundEnabled: enabled);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, enabled);
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
    SoundService().updateSettings(hapticsEnabled: enabled);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHaptics, enabled);
  }
}
