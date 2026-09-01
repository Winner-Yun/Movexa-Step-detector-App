import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_detector/core/constants/app_colors.dart';
import 'package:step_detector/core/theme/app_theme_extension.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffold,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.scaffold,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGradientEnd,
        primary: AppColors.primaryGradientEnd,
        onPrimary: AppColors.darkText,
        surface: AppColors.surface,
        onSurface: AppColors.darkText,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryGradientEnd,
        contentTextStyle: GoogleFonts.nokora(
          color: AppColors.activityCard,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
      extensions: const [AppThemeExtension.light],
      textTheme: GoogleFonts.kantumruyProTextTheme().copyWith(
        headlineSmall: GoogleFonts.nokora(
          fontSize: 27,
          fontWeight: FontWeight.w800,
        ),
        displaySmall: GoogleFonts.nokora(
          fontSize: 46,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
        titleMedium: GoogleFonts.nokora(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: GoogleFonts.nokora(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.scaffoldDark,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: AppColors.primaryYellow,
        primary: AppColors.primaryYellow,
        onPrimary: AppColors.textLight,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textLight,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryGradientEnd,
        contentTextStyle: GoogleFonts.nokora(
          color: AppColors.activityCard, // Keep text dark on yellow bg
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
      extensions: const [AppThemeExtension.dark],
      textTheme:
          GoogleFonts.kantumruyProTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme,
          ).copyWith(
            headlineSmall: GoogleFonts.nokora(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: AppColors.textLight,
            ),
            displaySmall: GoogleFonts.nokora(
              fontSize: 46,
              fontWeight: FontWeight.w900,
              height: 1,
              color: AppColors.textLight,
            ),
            titleMedium: GoogleFonts.nokora(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
            ),
            bodyMedium: GoogleFonts.nokora(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.mutedTextLight,
            ),
          ),
    );
  }
}
