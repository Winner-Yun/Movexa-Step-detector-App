import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:step_detector/core/constants/app_colors.dart';
import 'package:step_detector/data/controller/activity_controller.dart';
import 'package:step_detector/data/controller/motion_controller.dart';
import 'package:step_detector/data/controller/profile_controller.dart';
import 'package:step_detector/data/controller/settings_controller.dart';
import 'package:step_detector/widgets/activity_section.dart';
import 'package:step_detector/widgets/dashboard_widgets.dart';
import 'package:step_detector/widgets/primary_button.dart';
import 'package:step_detector/widgets/stat_card.dart';
import 'package:step_detector/widgets/tracking_toggle_card.dart';

class StepDashboardPage extends StatefulWidget {
  const StepDashboardPage({super.key});

  @override
  State<StepDashboardPage> createState() => _StepDashboardPageState();
}

class _StepDashboardPageState extends State<StepDashboardPage> {
  final TextEditingController _goalInputController = TextEditingController();

  @override
  void dispose() {
    _goalInputController.dispose();
    super.dispose();
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  void _showSetGoalDialog(
    BuildContext context,
    SettingsController settingsCtrl,
  ) {
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: AppColors.surface,
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogHeader(),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _goalInputController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      cursorColor: AppColors.brandAccent,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.brandAccent,
                      ),
                      onChanged: (value) {
                        if (errorMessage != null) {
                          setState(() => errorMessage = null);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: '${settingsCtrl.settings.dailyStepGoal}',
                        hintStyle: TextStyle(
                          color: AppColors.brandAccent.withValues(alpha: 0.3),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        filled: true,
                        fillColor: AppColors.scaffoldSoft,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        errorText: errorMessage,
                        errorStyle: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _goalInputController.clear();
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'បោះបង់',
                              style: TextStyle(
                                color: AppColors.mutedText,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final newGoal = int.tryParse(
                                _goalInputController.text,
                              );
                              if (newGoal != null && newGoal > 0) {
                                settingsCtrl.updateStepGoal(newGoal);
                                _showSnack('បានកំណត់គោលដៅថ្មី: $newGoal');
                                Navigator.pop(context);
                                _goalInputController.clear();
                              } else {
                                setState(
                                  () => errorMessage =
                                      'សូមបញ្ចូលចំនួនឲ្យបានត្រឹមត្រូវ',
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandAccent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'រក្សាទុក',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.brandAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.flag_rounded,
            color: AppColors.brandAccent,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'កំណត់គោលដៅថ្មី',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'កំណត់គោលដៅជំហានប្រចាំថ្ងៃរបស់អ្នក',
          style: TextStyle(
            color: AppColors.mutedText,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTopHeader(TextTheme textTheme) {
    return Row(
      children: [
        const Icon(
          Icons.fitness_center_rounded,
          size: 17,
          color: AppColors.brandAccent,
        ),
        const SizedBox(width: 6),
        Text(
          'Kinetic',
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.brandAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(TextTheme textTheme, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.isEmpty ? 'សួស្តី!' : 'សួស្តី $name!',
          style: textTheme.headlineSmall?.copyWith(
            color: AppColors.darkText,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'បន្តដំណើរ! ថ្ងៃនេះល្អណាស់',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.mutedText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _onTrackingToggled(
    bool val,
    SettingsController settingsCtrl,
    MotionController motionCtrl,
    ActivityController activityCtrl,
  ) async {
    final newSettings = settingsCtrl.settings.copyWith(
      runTrackingInBackground: val,
    );
    settingsCtrl.updateSettings(newSettings);

    if (val) {
      await motionCtrl.start(
        dailyGoal: settingsCtrl.settings.dailyStepGoal,
        alreadyCountedToday: activityCtrl.todayRecord?.steps ?? 0,
      );
      if (motionCtrl.permissionDenied) {
        _showSnack('Motion & Fitness permission is required to track steps.');
      }
    } else {
      motionCtrl.stop();
    }
  }

  Widget _buildStatsGrid(dynamic todayRecord) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.pin_drop_rounded,
            iconColor: const Color(0xFFB57D1D),
            title: 'ចម្ងាយ',
            value: (todayRecord?.distance ?? 0.0).toStringAsFixed(2),
            unit: 'KM',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFD45529),
            title: 'កាឡូរី',
            value: (todayRecord?.calories ?? 0.0).toStringAsFixed(0),
            unit: 'KCAL',
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesHeader(TextTheme textTheme) {
    return Row(
      children: [
        Text(
          'សកម្មភាពថ្មីៗ',
          style: textTheme.titleSmall?.copyWith(
            color: AppColors.darkText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => _showSnack('See all tapped'),
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          ),
          child: Text(
            'See all',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.brandAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final profileCtrl = context.watch<ProfileController>();
    final settingsCtrl = context.watch<SettingsController>();
    final activityCtrl = context.watch<ActivityController>();
    final motionCtrl = context.watch<MotionController>();

    final todayRecord = activityCtrl.todayRecord;
    final currentSteps = todayRecord?.steps ?? 0;
    final goal = settingsCtrl.settings.dailyStepGoal;
    final progress = (currentSteps / goal).clamp(0.0, 1.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopHeader(textTheme),
                  const SizedBox(height: 14),
                  _buildGreeting(
                    textTheme,
                    profileCtrl.currentProfile?.name ?? "",
                  ),
                  const SizedBox(height: 12),

                  ProgressPanel(
                    progress: progress,
                    steps: currentSteps,
                    progressGreen: AppColors.progressValue,
                    textColor: AppColors.darkText,
                    subTextColor: AppColors.mutedText,
                  ),
                  const SizedBox(height: 12),

                  TrackingToggleCard(
                    enabled: settingsCtrl.settings.runTrackingInBackground,
                    motionStatus: motionCtrl.status,
                    isTracking: motionCtrl.isTracking,
                    permissionDenied: motionCtrl.permissionDenied,
                    onChanged: (val) => _onTrackingToggled(
                      val,
                      settingsCtrl,
                      motionCtrl,
                      activityCtrl,
                    ),
                  ),
                  const SizedBox(height: 12),

                  PrimaryButton(
                    onTap: () => _showSetGoalDialog(context, settingsCtrl),
                    text: 'កំណត់គោលដៅថ្មី',
                  ),
                  const SizedBox(height: 14),

                  _buildStatsGrid(todayRecord),
                  const SizedBox(height: 14),

                  _buildRecentActivitiesHeader(textTheme),
                  const SizedBox(height: 8),

                  ActivitySection(activities: activityCtrl.workoutHistory),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
