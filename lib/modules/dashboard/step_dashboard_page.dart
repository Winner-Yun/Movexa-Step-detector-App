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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${context.read<AppTranslations>().tr('newGoalSet')}$newGoal'),
              ),
            );
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

  Future<void> _onRefresh(BuildContext context) async {
    final activityCtrl = context.read<ActivityController>();
    final profileCtrl = context.read<ProfileController>();
    final settingsCtrl = context.read<SettingsController>();

    if (activityCtrl.isFetching) return;

    activityCtrl.setFetching(true);
    
    await Future.wait([
      profileCtrl.fetchProfile(),
      settingsCtrl.fetchSettings(),
      activityCtrl.fetchTodayRecord(dailyGoal: settingsCtrl.settings.dailyStepGoal),
      activityCtrl.fetchWorkoutHistory(),
      activityCtrl.fetchMonthlyStepHistory(),
    ]);

    activityCtrl.setFetching(false);
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

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _onRefresh(context),
          color: ThemeColors.getBrandAccent(context),
          backgroundColor: ThemeColors.getSurface(context),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: activityCtrl.isFetching || profileCtrl.isLoading
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                    children: [
                      _buildTopHeader(textTheme),
                      const SizedBox(height: 14),
                      const DashboardSkeleton(),
                    ],
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
