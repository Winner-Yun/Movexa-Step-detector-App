import 'package:flutter/material.dart';
import 'package:step_detector/core/theme/app_theme_extension.dart';

class ThemeColors {
  static AppThemeExtension _get(BuildContext context) {
    return Theme.of(context).extension<AppThemeExtension>()!;
  }

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color getPrimaryYellow(BuildContext context) =>
      _get(context).primaryYellow;
  static Color getText(BuildContext context) => _get(context).text;
  static Color getMutedText(BuildContext context) => _get(context).mutedText;

  static Color getScaffold(BuildContext context) => _get(context).scaffold;
  static Color getScaffoldSoft(BuildContext context) =>
      _get(context).scaffoldSoft;
  static Color getSurface(BuildContext context) => _get(context).surface;

  static Color getNavBackground(BuildContext context) =>
      _get(context).navBackground;
  static Color getNavSelected(BuildContext context) =>
      _get(context).navSelected;
  static Color getNavUnselected(BuildContext context) =>
      _get(context).navUnselected;

  static Color getBrandAccent(BuildContext context) =>
      _get(context).brandAccent;
  static Color getPrimaryGradientStart(BuildContext context) =>
      _get(context).primaryGradientStart;
  static Color getPrimaryGradientEnd(BuildContext context) =>
      _get(context).primaryGradientEnd;

  static Color getProgressTrack(BuildContext context) =>
      _get(context).progressTrack;
  static Color getProgressValue(BuildContext context) =>
      _get(context).progressValue;
  static Color getProgressChip(BuildContext context) =>
      _get(context).progressChip;
  static Color getProgressChipText(BuildContext context) =>
      _get(context).progressChipText;

  static Color getCardNeutral(BuildContext context) =>
      _get(context).cardNeutral;
  static Color getActivityCard(BuildContext context) =>
      _get(context).activityCard;
  static Color getIconChip(BuildContext context) => _get(context).iconChip;

  static Color getPositiveText(BuildContext context) =>
      _get(context).positiveText;
}
