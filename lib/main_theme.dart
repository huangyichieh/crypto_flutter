import 'package:flutter/material.dart';

const _bgDark = Color(0xFF0B1220);
const _bgSurface = Color(0xFF111827);
const _fgPrimary = Color(0xFFE5E7EB);
const _fgMuted = Color(0xFF94A3B8);
const _accent = Color(0xFF38BDF8);

final pcTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: _accent,
    onPrimary: _bgDark,
    secondary: Color(0xFF22D3EE),
    onSecondary: _bgDark,
    surface: _bgSurface,
    onSurface: _fgPrimary,
    error: Color(0xFFF87171),
    onError: _bgDark,
  ),
  primaryColor: _accent,
  scaffoldBackgroundColor: _bgDark,
  cardTheme: CardThemeData(
    color: _bgSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: Color(0xFF1F2937)),
      borderRadius: BorderRadius.circular(14),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: _bgSurface,
    foregroundColor: _fgPrimary,
    actionsIconTheme: IconThemeData(color: _fgPrimary),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 16)),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0xFF334155);
        }
        if (states.contains(WidgetState.pressed)) {
          return const Color(0xFF0EA5E9);
        }
        return _accent;
      }),
      foregroundColor: WidgetStateProperty.all(_bgDark),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 16)),
      foregroundColor: WidgetStateProperty.all(_accent),
    ),
  ),

  inputDecorationTheme: const InputDecorationTheme(
    fillColor: _bgSurface,
    filled: true,
    border: OutlineInputBorder(),
    errorStyle: TextStyle(color: Color(0xFFF87171)),
  ),

  dividerTheme: const DividerThemeData(color: Color(0xFF1F2937)),

  tabBarTheme: const TabBarThemeData(
    labelColor: _accent,
    labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    unselectedLabelStyle: TextStyle(fontSize: 18, color: _fgMuted),
  ),

  textTheme: const TextTheme(
    bodySmall: TextStyle(fontSize: 12, color: _fgMuted),
    bodyMedium: TextStyle(fontSize: 14, color: _fgPrimary),
    bodyLarge: TextStyle(fontSize: 16, color: _fgPrimary),
    labelSmall: TextStyle(fontSize: 12, color: _fgMuted),
    labelMedium: TextStyle(fontSize: 14, color: _fgPrimary),
    labelLarge: TextStyle(fontSize: 16, color: _fgPrimary),
    titleSmall: TextStyle(fontSize: 16, color: _fgPrimary),
    titleMedium: TextStyle(fontSize: 18, color: _fgPrimary),
    titleLarge: TextStyle(fontSize: 20, color: _fgPrimary),
    headlineSmall: TextStyle(fontSize: 20, color: _fgPrimary),
    headlineMedium: TextStyle(fontSize: 22, color: _fgPrimary),
    headlineLarge: TextStyle(fontSize: 24, color: _fgPrimary),
    displaySmall: TextStyle(fontSize: 28, color: _fgPrimary),
    displayMedium: TextStyle(fontSize: 32, color: _fgPrimary),
    displayLarge: TextStyle(fontSize: 36, color: _fgPrimary),
  ),
  canvasColor: _bgDark,
);
