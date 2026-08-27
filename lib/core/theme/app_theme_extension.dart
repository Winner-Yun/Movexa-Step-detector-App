import 'package:flutter/material.dart';
import 'package:step_detector/core/constants/app_colors.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color primaryYellow;
  final Color text;
  final Color mutedText;
  
  final Color scaffold;
  final Color scaffoldSoft;
  final Color surface;
  
  final Color navBackground;
  final Color navSelected;
  final Color navUnselected;
  
  final Color brandAccent;
  final Color primaryGradientStart;
  final Color primaryGradientEnd;
  
  final Color progressTrack;
  final Color progressValue;
  final Color progressChip;
  final Color progressChipText;
  
  final Color cardNeutral;
  final Color activityCard;
  final Color iconChip;
  
  final Color positiveText;

  const AppThemeExtension({
    required this.primaryYellow,
    required this.text,
    required this.mutedText,
    required this.scaffold,
    required this.scaffoldSoft,
    required this.surface,
    required this.navBackground,
    required this.navSelected,
    required this.navUnselected,
    required this.brandAccent,
    required this.primaryGradientStart,
    required this.primaryGradientEnd,
    required this.progressTrack,
    required this.progressValue,
    required this.progressChip,
    required this.progressChipText,
    required this.cardNeutral,
    required this.activityCard,
    required this.iconChip,
    required this.positiveText,
  });

  @override
  AppThemeExtension copyWith({
    Color? primaryYellow,
    Color? text,
    Color? mutedText,
    Color? scaffold,
    Color? scaffoldSoft,
    Color? surface,
    Color? navBackground,
    Color? navSelected,
    Color? navUnselected,
    Color? brandAccent,
    Color? primaryGradientStart,
    Color? primaryGradientEnd,
    Color? progressTrack,
    Color? progressValue,
    Color? progressChip,
    Color? progressChipText,
    Color? cardNeutral,
    Color? activityCard,
    Color? iconChip,
    Color? positiveText,
  }) {
    return AppThemeExtension(
      primaryYellow: primaryYellow ?? this.primaryYellow,
      text: text ?? this.text,
      mutedText: mutedText ?? this.mutedText,
      scaffold: scaffold ?? this.scaffold,
      scaffoldSoft: scaffoldSoft ?? this.scaffoldSoft,
      surface: surface ?? this.surface,
      navBackground: navBackground ?? this.navBackground,
      navSelected: navSelected ?? this.navSelected,
      navUnselected: navUnselected ?? this.navUnselected,
      brandAccent: brandAccent ?? this.brandAccent,
      primaryGradientStart: primaryGradientStart ?? this.primaryGradientStart,
      primaryGradientEnd: primaryGradientEnd ?? this.primaryGradientEnd,
      progressTrack: progressTrack ?? this.progressTrack,
      progressValue: progressValue ?? this.progressValue,
      progressChip: progressChip ?? this.progressChip,
      progressChipText: progressChipText ?? this.progressChipText,
      cardNeutral: cardNeutral ?? this.cardNeutral,
      activityCard: activityCard ?? this.activityCard,
      iconChip: iconChip ?? this.iconChip,
      positiveText: positiveText ?? this.positiveText,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      primaryYellow: Color.lerp(primaryYellow, other.primaryYellow, t)!,
      text: Color.lerp(text, other.text, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      scaffold: Color.lerp(scaffold, other.scaffold, t)!,
      scaffoldSoft: Color.lerp(scaffoldSoft, other.scaffoldSoft, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      navBackground: Color.lerp(navBackground, other.navBackground, t)!,
      navSelected: Color.lerp(navSelected, other.navSelected, t)!,
      navUnselected: Color.lerp(navUnselected, other.navUnselected, t)!,
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
      primaryGradientStart: Color.lerp(primaryGradientStart, other.primaryGradientStart, t)!,
      primaryGradientEnd: Color.lerp(primaryGradientEnd, other.primaryGradientEnd, t)!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      progressValue: Color.lerp(progressValue, other.progressValue, t)!,
      progressChip: Color.lerp(progressChip, other.progressChip, t)!,
      progressChipText: Color.lerp(progressChipText, other.progressChipText, t)!,
      cardNeutral: Color.lerp(cardNeutral, other.cardNeutral, t)!,
      activityCard: Color.lerp(activityCard, other.activityCard, t)!,
      iconChip: Color.lerp(iconChip, other.iconChip, t)!,
      positiveText: Color.lerp(positiveText, other.positiveText, t)!,
    );
  }

  static const AppThemeExtension light = AppThemeExtension(
    primaryYellow: AppColors.primaryYellow,
    text: AppColors.darkText,
    mutedText: AppColors.mutedText,
    scaffold: AppColors.scaffold,
    scaffoldSoft: AppColors.scaffoldSoft,
    surface: AppColors.surface,
    navBackground: AppColors.navBackground,
    navSelected: AppColors.navSelected,
    navUnselected: AppColors.navUnselected,
    brandAccent: AppColors.brandAccent,
    primaryGradientStart: AppColors.primaryGradientStart,
    primaryGradientEnd: AppColors.primaryGradientEnd,
    progressTrack: AppColors.progressTrack,
    progressValue: AppColors.progressValue,
    progressChip: AppColors.progressChip,
    progressChipText: AppColors.progressChipText,
    cardNeutral: AppColors.cardNeutral,
    activityCard: AppColors.activityCard,
    iconChip: AppColors.iconChip,
    positiveText: AppColors.positiveText,
  );

  static const AppThemeExtension dark = AppThemeExtension(
    primaryYellow: AppColors.primaryYellow,
    text: AppColors.textLight,
    mutedText: AppColors.mutedTextLight,
    scaffold: AppColors.scaffoldDark,
    scaffoldSoft: AppColors.scaffoldSoftDark,
    surface: AppColors.surfaceDark,
    navBackground: AppColors.navBackgroundDark,
    navSelected: AppColors.navSelectedDark,
    navUnselected: AppColors.navUnselectedDark,
    brandAccent: AppColors.brandAccentDark,
    primaryGradientStart: AppColors.primaryGradientStartDark,
    primaryGradientEnd: AppColors.primaryGradientEndDark,
    progressTrack: AppColors.progressTrackDark,
    progressValue: AppColors.progressValueDark,
    progressChip: AppColors.progressChipDark,
    progressChipText: AppColors.progressChipTextDark,
    cardNeutral: AppColors.cardNeutralDark,
    activityCard: AppColors.activityCardDark,
    iconChip: AppColors.iconChipDark,
    positiveText: AppColors.positiveTextDark,
  );
}
