import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_detector/core/constants/app_img.dart';
import 'package:step_detector/core/localization/app_translations.dart';
import 'package:step_detector/core/theme/theme_colors.dart';
import 'package:step_detector/data/controller/activity_controller.dart';
import 'package:step_detector/data/controller/motion_controller.dart';
import 'package:step_detector/data/controller/profile_controller.dart';
import 'package:step_detector/data/controller/settings_controller.dart';
import 'package:step_detector/widgets/activity_section.dart';
import 'package:step_detector/widgets/dashboard_widgets.dart';
import 'package:step_detector/widgets/primary_button.dart';
import 'package:step_detector/widgets/skeleton.dart';
import 'package:step_detector/widgets/stat_card.dart';
import 'package:step_detector/widgets/tracking_toggle_card.dart';
import 'package:step_detector/widgets/set_goal_dialog.dart';

class StepDashboardPage extends StatefulWidget {
  const StepDashboardPage({super.key, this.onSeeAll});
  final VoidCallback? onSeeAll;

  @override
  State<StepDashboardPage> createState() => _StepDashboardPageState();
}

class _StepDashboardPageState extends State<StepDashboardPage> {
  @override
  void dispose() {
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
    showDialog(
      context: context,
      builder: (context) {
        return SetGoalDialog(
          currentGoal: settingsCtrl.settings.dailyStepGoal,
          onGoalChanged: (newGoal) {
            settingsCtrl.updateStepGoal(newGoal);
            _showSuccessDialog(context, newGoal);
          },
        );
      },
    );
  }

  Widget _buildTopHeader(TextTheme textTheme) {
    return Row(
      children: [
        Image.asset(AppImg.logo, width: 40, height: 40),
        SizedBox(width: 6),
        Text(
          'Movexa',
          style: textTheme.labelLarge?.copyWith(
            color: ThemeColors.getBrandAccent(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: ThemeColors.getPrimaryYellow(context).withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog(BuildContext context, int newGoal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: ThemeColors.getSurface(context),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeColors.getProgressValue(
                      context,
                    ).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: ThemeColors.getProgressValue(context),
                    size: 48,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'savedSuccessfully'.tr(context),
                  style: TextStyle(
                    color: ThemeColors.getText(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${'newGoalSet'.tr(context)}$newGoal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ThemeColors.getMutedText(context),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.getBrandAccent(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'close'.tr(context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreeting(TextTheme textTheme, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.isEmpty ? 'hello'.tr(context) : '${'hello'.tr(context)} $name',
          style: textTheme.headlineSmall?.copyWith(
            color: ThemeColors.getText(context),
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 3),
        Text(
          'keepGoing'.tr(context),
          style: textTheme.bodyMedium?.copyWith(
            color: ThemeColors.getMutedText(context),
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
    // Fire and forget update to avoid blocking UI on firestore save
    settingsCtrl.updateSettings(newSettings);

    if (val) {
      await motionCtrl.start(
        dailyGoal: settingsCtrl.settings.dailyStepGoal,
        alreadyCountedToday: activityCtrl.todayRecord?.steps ?? 0,
        runInBackground: val,
      );
      if (motionCtrl.permissionDenied) {
        if (!mounted) return;
        _showSnack(context.read<AppTranslations>().tr('motionPermissionRequired'));
      }
    } else {
      motionCtrl.stop();
      final steps = motionCtrl.todaySteps;
      final distance = (steps * MotionController.kmPerStep).toDouble();
      final calories = (steps * MotionController.kcalPerStep).toDouble();
      await activityCtrl.updateTodaySteps(steps, distance, calories);
    }
  }

  Widget _buildStatsGrid(dynamic todayRecord) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.pin_drop_rounded,
            iconColor: const Color(0xFFB57D1D),
            title: 'distance'.tr(context),
            value: (todayRecord?.distance ?? 0.0).toStringAsFixed(2),
            unit: 'KM',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: StatCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFD45529),
            title: 'calories'.tr(context),
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
          'activityHistory'.tr(context),
          style: textTheme.titleSmall?.copyWith(
            color: ThemeColors.getText(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            if (widget.onSeeAll != null) {
              widget.onSeeAll!();
            } else {
              _showSnack('${'seeAll'.tr(context)} tapped');
            }
          },
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          ),
          child: Text(
            'seeAll'.tr(context),
            style: textTheme.labelMedium?.copyWith(
              color: ThemeColors.getBrandAccent(context),
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

    if (activityCtrl.isFetching || profileCtrl.isLoading) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopHeader(textTheme),
                  SizedBox(height: 14),
                  const DashboardSkeleton(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopHeader(textTheme),
                SizedBox(height: 14),
                _buildGreeting(
                  textTheme,
                  profileCtrl.currentProfile?.name ?? "",
                ),
                SizedBox(height: 12),

                ProgressPanel(
                  progress: progress,
                  steps: currentSteps,
                  goal: goal,
                  progressGreen: ThemeColors.getProgressValue(context),
                  textColor: ThemeColors.getText(context),
                  subTextColor: ThemeColors.getMutedText(context),
                ),
                SizedBox(height: 12),

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
                SizedBox(height: 12),

                PrimaryButton(
                  onTap: () => _showSetGoalDialog(context, settingsCtrl),
                  text: 'setNewGoal'.tr(context),
                ),
                SizedBox(height: 14),

                _buildStatsGrid(todayRecord),
                SizedBox(height: 14),

                _buildRecentActivitiesHeader(textTheme),
                SizedBox(height: 8),

                ActivitySection(activities: activityCtrl.monthlyStepHistory),

                SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
