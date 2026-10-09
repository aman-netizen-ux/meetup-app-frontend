import 'package:flutter/material.dart';

/// The shared visual foundation for every screen in Meetup.
///
/// Screens use ColorScheme roles instead of choosing light colours directly,
/// so the same component is readable in either system appearance.
abstract final class MeetupTheme {
  static final ThemeData light = _build(
    brightness: Brightness.light,
    canvas: const Color(0xFFF7F4EE),
    scheme: const ColorScheme.light(
      primary: Color(0xFF087E76),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFC7F1EA),
      onPrimaryContainer: Color(0xFF003C38),
      secondary: Color(0xFFE55E48),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFDAD1),
      onSecondaryContainer: Color(0xFF5B170D),
      surface: Colors.white,
      onSurface: Color(0xFF17283E),
      surfaceContainerHighest: Color(0xFFE6ECE9),
      onSurfaceVariant: Color(0xFF5C6B78),
      outline: Color(0xFF77838D),
      error: Color(0xFFB3261E),
      onError: Colors.white,
    ),
  );

  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    canvas: const Color(0xFF0D1824),
    scheme: const ColorScheme.dark(
      primary: Color(0xFF68D7C9),
      onPrimary: Color(0xFF003C38),
      primaryContainer: Color(0xFF075F58),
      onPrimaryContainer: Color(0xFFC7F1EA),
      secondary: Color(0xFFFF8C76),
      onSecondary: Color(0xFF5B170D),
      secondaryContainer: Color(0xFF813025),
      onSecondaryContainer: Color(0xFFFFDAD1),
      surface: Color(0xFF17283E),
      onSurface: Color(0xFFF2F7F5),
      surfaceContainerHighest: Color(0xFF263B50),
      onSurfaceVariant: Color(0xFFC1CCC8),
      outline: Color(0xFF8B9A9F),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
    ),
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color canvas,
    required ColorScheme scheme,
  }) => ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: canvas,
    appBarTheme: AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.45)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.45)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.surfaceContainerHighest,
      contentTextStyle: TextStyle(color: scheme.onSurface),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
