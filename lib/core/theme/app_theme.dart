import 'package:flutter/material.dart';

// ceci est la palette des couleurs que nous avons utiliser dans notre applications
abstract final class AppTheme {
  static const orangePrincipal = Color(0xFFFF7417);
  static const orangeFonce = Color(0xFFE85D00);
  static const noir = Color(0xFF0D0D0D);
  static const blanc = Color(0xFFFFFFFF);
  static const grisClair = Color(0xFFF7F8FA);
  static const grisTexte = Color(0xFF718096);

  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: orangePrincipal,
          brightness: Brightness.light,
        ).copyWith(
          primary: orangePrincipal,
          onPrimary: blanc,
          primaryContainer: const Color(0xFFFFE2D0),
          onPrimaryContainer: const Color(0xFF351000),
          secondary: noir,
          onSecondary: blanc,
          surface: grisClair,
          onSurface: noir,
          onSurfaceVariant: grisTexte,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: grisClair,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: grisClair,
        foregroundColor: noir,
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: orangePrincipal,
          foregroundColor: blanc,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: orangePrincipal,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: orangePrincipal,
        selectionColor: Color(0x55FF7417),
        selectionHandleColor: orangePrincipal,
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: orangePrincipal,
      brightness: Brightness.dark,
    ).copyWith(
      primary: orangePrincipal,
      onPrimary: blanc,
      secondary: blanc,
      surface: const Color(0xFF171717),
      onSurface: blanc,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: noir,
      cardTheme: const CardThemeData(
        color: Color(0xFF202020),
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: const ListTileThemeData(
        textColor: blanc,
        iconColor: Color(0xFFFFA66B),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF292929),
        thickness: .6,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF202020),
        labelStyle: const TextStyle(color: Color(0xFFCBCBCB)),
        hintStyle: const TextStyle(color: Color(0xFF929292)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF555555)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF555555)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF202020),
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF202020),
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: noir,
        foregroundColor: blanc,
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: orangePrincipal,
          foregroundColor: blanc,
        ),
      ),
    );
  }
}
