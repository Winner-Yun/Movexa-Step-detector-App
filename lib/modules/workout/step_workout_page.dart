import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  bool _isTracking = false;
  int _secondsElapsed = 0;
  DateTime? _workoutStartTime;
  Timer? _timer;

  final int _stepGoal = 50;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTracking() {
    if (_isTracking) {
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
          const SnackBar(
            content: Text(
              'ត្រូវការសិទ្ធិចលនាដើម្បីតាមដានជំហាន (Motion permission required)',
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isTracking = true;
      _secondsElapsed = 0;
      _workoutStartTime = DateTime.now();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsElapsed++);
    });
  }

  void _stopTracking() {
    _timer?.cancel();

    final motionCtrl = context.read<MotionController>();
    final steps = motionCtrl.stopWorkout();
    final duration = Duration(seconds: _secondsElapsed);
    final distanceKm = steps * kmPerStep;
    final calories = steps * kcalPerStep;

    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'ការហាត់ប្រាណ',
      startTime: _workoutStartTime ?? DateTime.now().subtract(duration),
      duration: duration,
      steps: steps,
      calories: calories,
      distance: distanceKm,
      averagePace: _formatPace(duration, distanceKm),
    );

    context.read<ActivityController>().saveWorkoutSession(session);

    setState(() => _isTracking = false);
    _showWorkoutSummaryDialog(steps, calories, distanceKm);
  }

  String _formatPace(Duration duration, double distanceKm) {
    if (distanceKm <= 0) return '0:00';
    final paceSecondsPerKm = duration.inSeconds / distanceKm;
    final paceMinutes = paceSecondsPerKm ~/ 60;
    final paceSeconds = (paceSecondsPerKm % 60).round();
    return '$paceMinutes:${paceSeconds.toString().padLeft(2, '0')}';
  }

  String get _formattedTime {
    final minutes = (_secondsElapsed / 60).floor().toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showWorkoutSummaryDialog(
    int steps,
    double calories,
    double distanceKm,
  ) {
    final bool isProud = steps >= _stepGoal;
    final caloriesLabel = calories.toStringAsFixed(1);
    final distanceLabel = distanceKm.toStringAsFixed(2);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            decoration: BoxDecoration(
              color: ThemeColors.getSurface(context),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: isProud
                      ? ThemeColors.getBrandAccent(
                          context,
                        ).withValues(alpha: 0.2)
                      : ThemeColors.getProgressChipText(context),
                  blurRadius: 40,
                  spreadRadius: 10,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                _buildSummaryFloatingIcon(isProud),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isProud ? 'ធ្វើបានល្អណាស់!' : 'កុំបោះបង់!',
                      style: TextStyle(
                        color: ThemeColors.getText(context),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      isProud
                          ? 'អ្នកបានសម្រេចគោលដៅថ្ងៃនេះ។'
                          : 'ការចាប់ផ្តើមគឺជាភាពជោគជ័យមួយ។',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ThemeColors.getMutedText(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 32),
                    _buildSummaryStatsGrid(steps, caloriesLabel, distanceLabel),
                    SizedBox(height: 32),
                    _buildSummaryCloseButton(isProud, context),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryFloatingIcon(bool isProud) {
    return Positioned(
      top: -80,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isProud
                ? [
                    ThemeColors.getPrimaryGradientStart(context),
                    ThemeColors.getPrimaryGradientEnd(context),
                  ]
                : [
                    ThemeColors.getProgressChipText(context),
                    ThemeColors.getProgressChipText(context),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isProud
                  ? ThemeColors.getBrandAccent(context).withValues(alpha: 0.4)
                  : ThemeColors.getProgressChipText(
                      context,
                    ).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          isProud ? Icons.emoji_events_rounded : Icons.directions_run_rounded,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildSummaryStatsGrid(int steps, String calories, String distance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getScaffoldSoft(context),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  Icons.timer_rounded,
                  Colors.orange,
                  _formattedTime,
                  'រយៈពេល',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: ThemeColors.getProgressTrack(context),
              ),
              Expanded(
                child: _buildSummaryItem(
                  Icons.do_not_step_rounded,
                  ThemeColors.getBrandAccent(context),
                  steps.toString(),
                  'ជំហាន',
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              color: ThemeColors.getProgressTrack(context),
              height: 1,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  Icons.local_fire_department_rounded,
                  const Color(0xFFD45529),
                  calories,
                  'KCAL',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: ThemeColors.getProgressTrack(context),
              ),
              Expanded(
                child: _buildSummaryItem(
                  Icons.route_rounded,
                  const Color(0xFF2980B9),
                  distance,
                  'KM',
                ),
              ),
            ],
          ),
        ],
      ),
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
          backgroundColor: isProud
              ? ThemeColors.getBrandAccent(context)
              : ThemeColors.getProgressChipText(context),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'បិទ (Close)',
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
          'ការហាត់ប្រាណ',
          style: textTheme.titleLarge?.copyWith(
            color: ThemeColors.getText(context),
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMainTimer(TextTheme textTheme, int currentSteps) {
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
                color: _isTracking
                    ? ThemeColors.getBrandAccent(context).withValues(alpha: 0.3)
                    : ThemeColors.getText(context).withValues(alpha: 0.05),
                blurRadius: _isTracking ? 50 : 20,
                spreadRadius: _isTracking ? 5 : 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 280,
          height: 280,
          child: CircularProgressIndicator(
            value: _isTracking ? null : 0.0,
            strokeWidth: 6,
            color: _isTracking
                ? ThemeColors.getBrandAccent(context)
                : ThemeColors.getScaffoldSoft(context),
            backgroundColor: ThemeColors.getScaffoldSoft(context),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isTracking ? Icons.timer_rounded : Icons.timer_off_rounded,
              color: _isTracking
                  ? ThemeColors.getBrandAccent(context)
                  : ThemeColors.getMutedText(context).withValues(alpha: 0.5),
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              _formattedTime,
              style: textTheme.displayMedium?.copyWith(
                color: _isTracking
                    ? ThemeColors.getBrandAccent(context)
                    : ThemeColors.getText(context),
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isTracking
                    ? ThemeColors.getProgressChip(context)
                    : ThemeColors.getScaffoldSoft(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.do_not_step_rounded,
                    color: _isTracking
                        ? ThemeColors.getProgressChipText(context)
                        : ThemeColors.getMutedText(context),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '$currentSteps ជំហាន',
                    style: textTheme.titleMedium?.copyWith(
                      color: _isTracking
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

  Widget _buildControlButton() {
    return GestureDetector(
      onTap: _toggleTracking,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isTracking
                ? [const Color(0xFFE53935), const Color(0xFFC62828)]
                : [
                    ThemeColors.getPrimaryGradientStart(context),
                    ThemeColors.getPrimaryGradientEnd(context),
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _isTracking
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
              _isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              _isTracking ? 'បញ្ឈប់ (Stop)' : 'ចាប់ផ្តើម (Start)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
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
    final currentSteps = _isTracking ? motionCtrl.workoutSteps : 0;
    final calories = currentSteps * kcalPerStep;
    final distance = currentSteps * kmPerStep;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPageHeader(textTheme),
              const Spacer(flex: 1),
              _buildMainTimer(textTheme, currentSteps),
              const Spacer(flex: 1),
              Row(
                children: [
                  Expanded(
                    child: _buildStatBox(
                      'កាឡូរី',
                      calories.toStringAsFixed(1),
                      'KCAL',
                      Icons.local_fire_department_rounded,
                      const Color(0xFFD45529),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatBox(
                      'ចម្ងាយ',
                      distance.toStringAsFixed(2),
                      'KM',
                      Icons.route_rounded,
                      const Color(0xFF2980B9),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              _buildControlButton(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
