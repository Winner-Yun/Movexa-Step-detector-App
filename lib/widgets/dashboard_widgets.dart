import 'package:flutter/material.dart';
import 'package:step_detector/core/theme/theme_colors.dart';
import 'package:step_detector/widgets/format_number.dart';

class ProgressPanel extends StatelessWidget {
  const ProgressPanel({
    super.key,
    required this.progress,
    required this.steps,
    required this.progressGreen,
    required this.textColor,
    required this.subTextColor,
  });

  final double progress;
  final int steps;
  final Color progressGreen;
  final Color textColor;
  final Color subTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ThemeColors.getScaffold(context),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 240,
                height: 240,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 10,
                  valueColor: AlwaysStoppedAnimation(
                    ThemeColors.getProgressTrack(context),
                  ),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 950),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      valueColor: AlwaysStoppedAnimation(progressGreen),
                      backgroundColor: Colors.transparent,
                    ),
                  );
                },
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatNumber(steps),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 40,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'ជំហាននៅថ្ងៃនេះ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: subTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColors.getProgressChip(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${(progress * 100).round()}% OF GOAL',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: ThemeColors.getProgressChipText(context),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
