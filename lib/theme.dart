import 'package:flutter/material.dart';

ThemeData buildDarkTheme() {
  const seed = Color(0xFF00D1FF);
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF0B0F14),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0B0F14),
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      iconTheme: IconThemeData(color: scheme.primary),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF0E141B),
      surfaceTintColor: Colors.transparent,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: const Color(0xFF0E141B),
      selectedIconTheme: IconThemeData(color: scheme.primary),
      selectedLabelTextStyle: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600),
      unselectedIconTheme: const IconThemeData(color: Colors.white70),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
      indicatorColor: scheme.primary.withValues(alpha: 0.12),
    ),
    dividerColor: Colors.white12,
    textTheme: const TextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}
