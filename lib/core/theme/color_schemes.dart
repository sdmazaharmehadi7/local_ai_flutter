import 'package:flutter/material.dart';

class AppColorSchemes {
  // Slate-indigo dark theme for a focused, technical aesthetic
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF6366F1), // Indigo
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF312E81),
    onPrimaryContainer: Color(0xFFE0E7FF),
    secondary: Color(0xFF0EA5E9), // Sky blue
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF0C4A6E),
    onSecondaryContainer: Color(0xFFBAE6FD),
    tertiary: Color(0xFF10B981), // Emerald
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFF064E3B),
    onTertiaryContainer: Color(0xFFA7F3D0),
    error: Color(0xFFF87171),
    onError: Color(0xFF450A0A),
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: Color(0xFFFEE2E2),
    surface: Color(0xFF0F172A), // Slate 900
    onSurface: Color(0xFFF8FAFC), // Slate 50
    surfaceContainerLowest: Color(0xFF020617), // Slate 950
    surfaceContainerLow: Color(0xFF0F172A),
    surfaceContainer: Color(0xFF1E293B), // Slate 800
    surfaceContainerHigh: Color(0xFF334155), // Slate 700
    surfaceContainerHighest: Color(0xFF475569), // Slate 600
    outline: Color(0xFF64748B), // Slate 500
    outlineVariant: Color(0xFF334155),
  );

  // Clean, high-contrast light theme
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF4F46E5), // Indigo 600
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFEEF2FF),
    onPrimaryContainer: Color(0xFF312E81),
    secondary: Color(0xFF0284C7), // Sky 600
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE0F2FE),
    onSecondaryContainer: Color(0xFF075985),
    tertiary: Color(0xFF059669), // Emerald 600
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFECFDF5),
    onTertiaryContainer: Color(0xFF065F46),
    error: Color(0xFFDC2626),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF991B1B),
    surface: Color(0xFFF8FAFC), // Slate 50
    onSurface: Color(0xFF0F172A), // Slate 900
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF1F5F9), // Slate 100
    surfaceContainer: Color(0xFFE2E8F0), // Slate 200
    surfaceContainerHigh: Color(0xFFCBD5E1), // Slate 300
    surfaceContainerHighest: Color(0xFF94A3B8), // Slate 400
    outline: Color(0xFF94A3B8),
    outlineVariant: Color(0xFFE2E8F0),
  );
}
