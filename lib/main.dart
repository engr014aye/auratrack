import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/habit_provider.dart';
import 'providers/reflection_provider.dart';
import 'providers/theme_provider.dart';
import 'views/screens/main_navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge system navigation & status bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize theme and preferences
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  // Initialize habit data
  final habitProvider = HabitProvider();
  await habitProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<HabitProvider>.value(value: habitProvider),
        ChangeNotifierProvider<ReflectionProvider>(create: (_) => ReflectionProvider()),
      ],
      child: const AuraTrackApp(),
    ),
  );
}

class AuraTrackApp extends StatelessWidget {
  const AuraTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'AuraTrack: Daily Routine & Habits',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MainNavigationShell(),
    );
  }
}
