import 'package:flutter/material.dart';

class AppTheme {
  static const Color _brandGreen = Color(0xFF16845B);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _brandGreen,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAF8),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8FAF8),
        foregroundColor: Color(0xFF17211C),
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 52),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),

      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
    );
  }

  // High contrast theme
  static ThemeData get highContrast {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ).copyWith(
          primary: Colors.black,
          onPrimary: Colors.white,

          primaryContainer: Colors.white,
          onPrimaryContainer: Colors.black,

          surface: Colors.white,
          onSurface: Colors.black,
          onSurfaceVariant: Colors.black,

          outline: Colors.black,
          outlineVariant: Colors.black,

          error: const Color(0xFFB00020),
          onError: Colors.white,
          errorContainer: Colors.white,
          onErrorContainer: const Color(0xFFB00020),

          surfaceTint: Colors.transparent,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Grey background makes white cards stand out.
      scaffoldBackgroundColor: const Color(0xFFE6E6E6),

      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),

      iconTheme: const IconThemeData(color: Colors.black),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 56),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.black, width: 2),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 56),
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black, width: 2),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      dividerTheme: const DividerThemeData(color: Colors.black, thickness: 1.5),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.black
              : Colors.white;
        }),
        trackColor: WidgetStateProperty.all(const Color(0xFFE0E0E0)),
        trackOutlineColor: WidgetStateProperty.all(Colors.black),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
