import 'package:flutter/material.dart';

abstract final class PulseColors {
  static const navy = Color(0xFF041636);
  static const blue = Color(0xFF075B87);
  static const cyan = Color(0xFF00BFD8);
  static const aqua = Color(0xFF14E4CD);
  static const teal = Color(0xFF007A78);
  static const background = Color(0xFFF7FAFC);
  static const ink = Color(0xFF10243B);
  static const muted = Color(0xFF526779);
  static const border = Color(0xFFDFE9EE);
  static const darkBackground = Color(0xFF071321);
  static const darkSurface = Color(0xFF0D2132);
  static const darkBorder = Color(0xFF284355);
  static const darkText = Color(0xFFF5FAFC);
  static const darkMuted = Color(0xFFACBFCA);
  static const darkPrimary = Color(0xFF49D6D2);
  static const danger = Color(0xFFB53040);
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF062552), Color(0xFF00629A)],
  );
}

ThemeData pulseTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: PulseColors.blue,
    brightness: brightness,
    primary: dark ? PulseColors.darkPrimary : PulseColors.blue,
    onPrimary: dark ? PulseColors.navy : Colors.white,
    surface: dark ? PulseColors.darkSurface : Colors.white,
    onSurface: dark ? PulseColors.darkText : PulseColors.ink,
    onSurfaceVariant: dark ? PulseColors.darkMuted : PulseColors.muted,
    outlineVariant: dark ? PulseColors.darkBorder : PulseColors.border,
    error: PulseColors.danger,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  return base.copyWith(
    scaffoldBackgroundColor: dark
        ? PulseColors.darkBackground
        : PulseColors.background,
    textTheme: base.textTheme.copyWith(
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -.8,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -.4,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.45),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: dark
          ? PulseColors.darkBackground
          : PulseColors.background,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      contentPadding: const EdgeInsets.all(16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primary.withValues(alpha: .12),
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 28),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
