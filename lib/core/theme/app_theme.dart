import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_detector/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldSoft,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryYellow,
        primary: AppColors.primaryYellow,
        onPrimary: AppColors.darkText,
        surface: AppColors.surface,
        onSurface: AppColors.darkText,
      ),
      textTheme: GoogleFonts.kantumruyProTextTheme().copyWith(
        headlineSmall: GoogleFonts.nokora(
          fontSize: 27,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
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
}
