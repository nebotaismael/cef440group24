import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
          surface: AppColors.white,
          background: AppColors.white,
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          onError: AppColors.white,
          onSurface: AppColors.textPrimary,
          onBackground: AppColors.textPrimary,
        ),
        textTheme: GoogleFonts.robotoTextTheme(
          ThemeData(brightness: Brightness.light).textTheme.apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: TextStyle(color: AppColors.textSecondary),
          hintStyle: TextStyle(color: AppColors.textHint),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColors.surface,
        ),
        iconTheme: IconThemeData(color: AppColors.primary),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            )
        )
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          primary: AppColors.darkPrimary,
          secondary: AppColors.darkSecondary,
          error: AppColors.error,
          surface: AppColors.darkSurface,
          background: AppColors.darkBackground,
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          onError: AppColors.white,
          onSurface: AppColors.darkTextPrimary,
          onBackground: AppColors.darkTextPrimary,
          surfaceVariant: AppColors.darkSurfaceVariant,
          onSurfaceVariant: AppColors.darkTextSecondary,
          outline: AppColors.darkBorder,
          outlineVariant: AppColors.darkDivider,
        ),
        textTheme: GoogleFonts.robotoTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme.apply(
            bodyColor: AppColors.darkTextPrimary,
            displayColor: AppColors.darkTextPrimary,
          ),
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkTextPrimary,
          surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPrimary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.darkPrimary, width: 2),
          ),
          labelStyle: TextStyle(color: AppColors.darkTextSecondary),
          hintStyle: TextStyle(color: AppColors.darkTextHint),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColors.darkCard,
        ),
        iconTheme: IconThemeData(color: AppColors.darkPrimary),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.darkPrimary,
            )
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.darkDivider,
          thickness: 1,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        dialogTheme: DialogTheme(
          backgroundColor: AppColors.darkSurface,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          contentTextStyle: TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 16,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.darkPrimary,
          unselectedItemColor: AppColors.darkTextSecondary,
          type: BottomNavigationBarType.fixed,
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: AppColors.darkSurface,
        ),
        listTileTheme: ListTileThemeData(
          textColor: AppColors.darkTextPrimary,
          iconColor: AppColors.darkTextSecondary,
        ),
    );
  }
}
