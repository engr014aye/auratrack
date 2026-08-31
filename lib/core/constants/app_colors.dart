import 'package:flutter/material.dart';

/// Central color definitions and category palettes for AuraTrack.
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF6366F1); // Indigo / Aura Purple
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color accent = Color(0xFFEC4899); // Electric Pink
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan Aura

  // Category Colors
  static const Color categoryMorning = Color(0xFFF59E0B); // Amber / Sunrise
  static const Color categoryAfternoon = Color(0xFF3B82F6); // Blue Sky
  static const Color categoryEvening = Color(0xFF8B5CF6); // Twilight Purple
  static const Color categoryHealth = Color(0xFF10B981); // Emerald Green
  static const Color categoryMind = Color(0xFFEC4899); // Lotus Pink
  static const Color categoryProductivity = Color(0xFF6366F1); // Focus Indigo

  // Mood Colors
  static const Color moodRad = Color(0xFF10B981); // Radiant Green
  static const Color moodGood = Color(0xFF3B82F6); // Serene Blue
  static const Color moodMeh = Color(0xFFF59E0B); // Neutral Amber
  static const Color moodDown = Color(0xFF8B5CF6); // Quiet Purple
  static const Color moodStressed = Color(0xFFEF4444); // High Alert Coral

  // Activity Ring Gradients
  static const List<Color> ringGradientMorning = [
    Color(0xFFFF7E5F),
    Color(0xFFFEB47B),
  ];
  static const List<Color> ringGradientHealth = [
    Color(0xFF00F260),
    Color(0xFF0575E6),
  ];
  static const List<Color> ringGradientMind = [
    Color(0xFFFA709A),
    Color(0xFFFEE140),
  ];
  static const List<Color> ringGradientProductivity = [
    Color(0xFF667EEA),
    Color(0xFF764BA2),
  ];

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1A1D26);
  static const Color darkSurfaceSecondary = Color(0xFF242836);
  static const Color darkCard = Color(0xFF1E2230);
  static const Color darkBorder = Color(0xFF2D3348);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFF1F5F9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF94A3B8);

  // Status & Utility
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Color options for habit creation
  static const List<Color> habitPalette = [
    Color(0xFF6366F1), // Indigo
    Color(0xFFEC4899), // Pink
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF43F5E), // Rose
    Color(0xFF14B8A6), // Teal
    Color(0xFFEAB308), // Yellow
    Color(0xFFD946EF), // Fuchsia
    Color(0xFF64748B), // Slate
  ];

  static Color fromHex(String hexString, {Color fallback = primary}) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  static String toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
