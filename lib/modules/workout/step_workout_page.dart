import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_detector/core/constants/app_img.dart';
import 'package:step_detector/core/localization/app_translations.dart';
import 'package:step_detector/core/theme/theme_colors.dart';
import 'package:step_detector/data/controller/activity_controller.dart';
import 'package:step_detector/data/controller/motion_controller.dart';
import 'package:step_detector/data/models/workout_session.dart';

class StepWorkoutPage extends StatefulWidget {
  const StepWorkoutPage({super.key});

  @override
  State<StepWorkoutPage> createState() => _StepWorkoutPageState();
}

class _StepWorkoutPageState extends State<StepWorkoutPage> {
  final int _stepGoal = 50;

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleTracking() {
    final motionCtrl = context.read<MotionController>();
    if (motionCtrl.isWorkoutActive) {
      _stopTracking();
    } else {
      _startTracking();
    }
  }

  Future<void> _startTracking() async {
    final motionCtrl = context.read<MotionController>();
    final started = await motionCtrl.startWorkout();

    if (!started) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<AppTranslations>().tr('motionPermissionRequired'),
            ),
          ),
        );
      }
      return;
    }
  }

  Future<void> _stopTracking() async {
    try {
      final motionCtrl = context.read<MotionController>();
      final durationSeconds = motionCtrl.workoutDurationSeconds;
      final steps = await motionCtrl.stopWorkout();
      final duration = Duration(seconds: durationSeconds);
      final distanceKm = (steps * MotionController.kmPerStep).toDouble();
      final calories = (steps * MotionController.kcalPerStep).toDouble();

      final speedKmh = duration.inSeconds > 0
          ? distanceKm / (duration.inSeconds / 3600.0)
          : 0.0;

      final session = WorkoutSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'workout',
        startTime: DateTime.now().subtract(duration),
        duration: duration,
        steps: steps,
        calories: calories,
        distance: distanceKm,
        averagePace: _formatPace(duration, distanceKm),
        speedKmh: speedKmh,
      );

      if (!mounted) return;
      context.read<ActivityController>().saveWorkoutSession(session);

      _showWorkoutSummaryDialog(
        steps,
        calories,
        distanceKm,
        speedKmh,
        _getFormattedTime(durationSeconds),
      );
    } catch (e, stack) {
      debugPrint('Error stopping tracking: $e\n$stack');
    }
  }

  String _formatPace(Duration duration, double distanceKm) {
    if (distanceKm <= 0) return '0:00';
    final paceSecondsPerKm = duration.inSeconds / distanceKm;
    final paceMinutes = paceSecondsPerKm ~/ 60;
    final paceSeconds = (paceSecondsPerKm % 60).round();
    return '$paceMinutes:${paceSeconds.toString().padLeft(2, '0')}';
  }

  String _getFormattedTime(int secondsElapsed) {
    final minutes = (secondsElapsed / 60).floor().toString().padLeft(2, '0');
    final seconds = (secondsElapsed % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showWorkoutSummaryDialog(
    int steps,
    double calories,
    double distanceKm,
    double speedKmh,
    String formattedTime,
  ) {
    final bool isProud = steps >= _stepGoal;
    final caloriesLabel = calories.toStringAsFixed(1);
    final distanceLabel = distanceKm.toStringAsFixed(2);
    final speedLabel = speedKmh.toStringAsFixed(1);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ThemeColors.getSurface(context),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppImg.logo,
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Movexa',
                      style: TextStyle(
                        color: ThemeColors.getText(context),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  isProud ? 'greatJob'.tr(context) : 'dontGiveUp'.tr(context),
                  style: TextStyle(
                    color: ThemeColors.getText(context),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  isProud
                      ? 'goalReached'.tr(context)
                      : 'startingIsSuccess'.tr(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ThemeColors.getMutedText(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 32),
                _buildSummaryStatsGrid(
                  steps,
                  caloriesLabel,
                  distanceLabel,
                  speedLabel,
                  formattedTime,
                ),
                SizedBox(height: 32),
                _buildSummaryCloseButton(isProud, context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryStatsGrid(
    int steps,
    String calories,
    String distance,
    String speed,
    String time,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryItem(
              Icons.timer_rounded,
              Colors.orange,
              time,
              context.read<AppTranslations>().tr('duration'),
            ),
            _buildSummaryItem(
              Icons.directions_run_rounded,
              ThemeColors.getBrandAccent(context),
              steps.toString(),
              context.read<AppTranslations>().tr('steps'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryItem(
              Icons.local_fire_department_rounded,
              const Color(0xFFD45529),
              calories,
              'KCAL',
            ),
            _buildSummaryItem(
              Icons.route_rounded,
              const Color(0xFF2980B9),
              distance,
              'KM',
            ),
            _buildSummaryItem(
              Icons.speed_rounded,
              const Color(0xFF8E44AD),
              speed,
              'KM/H',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    IconData icon,
    Color color,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: ThemeColors.getText(context),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: ThemeColors.getMutedText(context),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCloseButton(bool isProud, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColors.getBrandAccent(context),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'close'.tr(context),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ThemeColors.getBrandAccent(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.directions_run_rounded,
            color: ThemeColors.getBrandAccent(context),
            size: 24,
          ),
        ),
        SizedBox(width: 12),
        Text(
          'workout'.tr(context),
          style: textTheme.titleLarge?.copyWith(
            color: ThemeColors.getText(context),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildMainTimer(
    TextTheme textTheme,
    int currentSteps,
    bool isTracking,
    String formattedTime,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ThemeColors.getSurface(context),
            boxShadow: [
              BoxShadow(
                color: isTracking
                    ? ThemeColors.getBrandAccent(context).withValues(alpha: 0.3)
                    : ThemeColors.getText(context).withValues(alpha: 0.05),
                blurRadius: isTracking ? 50 : 20,
                spreadRadius: isTracking ? 5 : 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 280,
          height: 280,
          child: CircularProgressIndicator(
            value: isTracking ? null : 0.0,
            strokeWidth: 6,
            color: isTracking
                ? ThemeColors.getBrandAccent(context)
                : ThemeColors.getScaffoldSoft(context),
            backgroundColor: ThemeColors.getScaffoldSoft(context),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isTracking ? Icons.timer_rounded : Icons.timer_off_rounded,
              color: isTracking
                  ? ThemeColors.getBrandAccent(context)
                  : ThemeColors.getMutedText(context).withValues(alpha: 0.5),
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              formattedTime,
              style: textTheme.displayMedium?.copyWith(
                color: isTracking
                    ? ThemeColors.getBrandAccent(context)
                    : ThemeColors.getText(context),
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isTracking
                    ? ThemeColors.getProgressChip(context)
                    : ThemeColors.getScaffoldSoft(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_run_rounded,
                    color: isTracking
                        ? ThemeColors.getProgressChipText(context)
                        : ThemeColors.getMutedText(context),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '$currentSteps ${'steps'.tr(context)}',
                    style: textTheme.titleMedium?.copyWith(
                      color: isTracking
                          ? ThemeColors.getProgressChipText(context)
                          : ThemeColors.getMutedText(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox(
    String title,
    String value,
    String unit,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getText(context).withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: ThemeColors.getMutedText(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: ThemeColors.getMutedText(
                      context,
                    ).withValues(alpha: 0.8),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(bool isTracking) {
    return GestureDetector(
      onTap: _toggleTracking,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isTracking
                ? [const Color(0xFFE53935), const Color(0xFFC62828)]
                : [
                    ThemeColors.getPrimaryGradientStart(context),
                    ThemeColors.getPrimaryGradientEnd(context),
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isTracking
                  ? const Color(0xFFE53935).withValues(alpha: 0.3)
                  : ThemeColors.getBrandAccent(context).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              isTracking ? 'stop'.tr(context) : 'start'.tr(context),
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final motionCtrl = context.watch<MotionController>();

    final isTracking = motionCtrl.isWorkoutActive;
    final currentSteps = isTracking ? motionCtrl.workoutSteps : 0;
    final calories = (currentSteps * MotionController.kcalPerStep).toDouble();
    final distance = (currentSteps * MotionController.kmPerStep).toDouble();
    final formattedTime = _getFormattedTime(motionCtrl.workoutDurationSeconds);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPageHeader(textTheme),
              const Spacer(flex: 1),
              _buildMainTimer(
                textTheme,
                currentSteps,
                isTracking,
                formattedTime,
              ),
              const Spacer(flex: 1),
              Row(
                children: [
                  Expanded(
                    child: _buildStatBox(
                      'calories'.tr(context),
                      calories.toStringAsFixed(1),
                      'KCAL',
                      Icons.local_fire_department_rounded,
                      const Color(0xFFD45529),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatBox(
                      'distance'.tr(context),
                      distance.toStringAsFixed(2),
                      'KM',
                      Icons.route_rounded,
                      const Color(0xFF2980B9),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              _buildControlButton(isTracking),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
