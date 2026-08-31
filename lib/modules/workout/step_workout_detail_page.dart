import 'package:flutter/material.dart';
import 'package:step_detector/core/localization/app_translations.dart';
import 'package:step_detector/core/theme/theme_colors.dart';
import 'package:step_detector/data/models/workout_session.dart';
import 'package:step_detector/widgets/share_image_dialog.dart';

class StepWorkoutDetailPage extends StatelessWidget {
  final WorkoutSession session;

  const StepWorkoutDetailPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ThemeColors.getText(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'details'.tr(context),
          style: textTheme.titleMedium?.copyWith(
            color: ThemeColors.getText(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.download_rounded,
              color: ThemeColors.getBrandAccent(context),
            ),
            tooltip: 'saveImage'.tr(context),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    ShareWorkoutSessionDialog(session: session),
              );
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          children: [
            _buildHeaderInfo(context, textTheme),
            SizedBox(height: 24),
            _buildMainHeroCard(context, textTheme),
            SizedBox(height: 24),
            _buildMetricsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  session.distance.toStringAsFixed(2),
                  style: textTheme.displayLarge?.copyWith(
                    color: ThemeColors.getText(context),
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'KM',
                  style: textTheme.titleLarge?.copyWith(
                    color: ThemeColors.getMutedText(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            '${session.startTime.day.toString().padLeft(2, '0')}/${session.startTime.month.toString().padLeft(2, '0')}/${session.startTime.year}',
            style: textTheme.bodyMedium?.copyWith(
              color: ThemeColors.getMutedText(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainHeroCard(BuildContext context, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: session.steps),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                value.toString(),
                style: textTheme.displayMedium?.copyWith(
                  color: ThemeColors.getBrandAccent(context),
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              );
            },
          ),
          SizedBox(height: 4),
          Text(
            'totalSteps'.tr(context),
            style: TextStyle(
              color: ThemeColors.getMutedText(context),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 16,
        children: [
          _buildTextStat(context, session.formattedDuration, 'នាទី'),
          _buildDivider(context),
          _buildTextStat(context, session.calories.toStringAsFixed(0), 'KCAL'),
          _buildDivider(context),
          _buildTextStat(context, session.speedKmh.toStringAsFixed(1), 'KM/H'),
        ],
      ),
    );
  }

  Widget _buildTextStat(BuildContext context, String value, String unit) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value $unit',
          style: TextStyle(
            color: ThemeColors.getText(context),
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Text(
      '|',
      style: TextStyle(
        color: ThemeColors.getMutedText(context).withValues(alpha: 0.3),
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
    );
  }
}
