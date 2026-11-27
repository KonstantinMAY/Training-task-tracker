
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/auth_gate.dart';

class TaskTrackerApp extends StatefulWidget {
  const TaskTrackerApp({super.key});

  @override
  State<TaskTrackerApp> createState() => _TaskTrackerAppState();
}

class _TaskTrackerAppState extends State<TaskTrackerApp> {
  ThemeMode themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkTheme') ?? false;

    if (mounted) {
      setState(() {
        themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  Future<void> toggleTheme() async {
    final nextMode = themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    setState(() => themeMode = nextMode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', nextMode == ThemeMode.dark);
  }

  ThemeData buildLightTheme() {
    const background = Color(0xFFF1F2F5);
    const foreground = Color(0xFF202938);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: foreground,
        brightness: Brightness.light,
        surface: Colors.white,
        primary: foreground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
      ),
      cardColor: Colors.white,
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F7F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFD5D9E0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFD5D9E0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: foreground,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  ThemeData buildDarkTheme() {
    const background = Color(0xFF000000);
    const surface = Color(0xFF1F1F1F);
    const accent = Color(0xFFFFD21F);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
        surface: surface,
        primary: accent,
        onPrimary: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: accent,
        elevation: 0,
        centerTitle: false,
      ),
      cardColor: surface,
      dialogTheme: const DialogThemeData(
        backgroundColor: surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF292929),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF444444),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF444444),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: accent,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskTracker',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      home: AuthGate(onToggleTheme: toggleTheme),
    );
  }
}
