import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:step_detector/core/constants/app_colors.dart';
import 'package:step_detector/data/controller/activity_controller.dart';
import 'package:step_detector/data/controller/motion_controller.dart';
import 'package:step_detector/data/controller/profile_controller.dart';
import 'package:step_detector/data/controller/settings_controller.dart';
import 'package:step_detector/modules/dashboard/step_dashboard_page.dart';
import 'package:step_detector/modules/history/step_history_page.dart';
import 'package:step_detector/modules/settings/step_settings_page.dart';
import 'package:step_detector/modules/workout/step_workout_page.dart';

class StepMainApp extends StatefulWidget {
  const StepMainApp({super.key});

  @override
  State<StepMainApp> createState() => _StepMainAppState();
}

class _StepMainAppState extends State<StepMainApp> {
  int _selectedTab = 0;

  static const List<Widget> _pages = [
    StepDashboardPage(),
    StepWorkoutPage(),
    StepHistoryPage(),
    StepSettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final profileCtrl = context.read<ProfileController>();
    final settingsCtrl = context.read<SettingsController>();
    final activityCtrl = context.read<ActivityController>();
    final motionCtrl = context.read<MotionController>();

    // Settings must resolve first so a first-time today's-record gets
    // seeded with the user's real daily goal, not a hardcoded fallback.
    await Future.wait([profileCtrl.fetchProfile(), settingsCtrl.fetchSettings()]);

    if (!mounted) return;
    await Future.wait([
      activityCtrl.fetchTodayRecord(dailyGoal: settingsCtrl.settings.dailyStepGoal),
      activityCtrl.fetchWorkoutHistory(),
      activityCtrl.fetchMonthlyStepHistory(),
    ]);

    if (!mounted) return;
    if (settingsCtrl.settings.runTrackingInBackground) {
      motionCtrl.start(
        dailyGoal: settingsCtrl.settings.dailyStepGoal,
        alreadyCountedToday: activityCtrl.todayRecord?.steps ?? 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: IndexedStack(index: _selectedTab, children: _pages),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        decoration: BoxDecoration(
          color: AppColors.navBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                index: 0,
                selectedIndex: _selectedTab,
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                onSelected: _onSelected,
              ),
            ),
            Expanded(
              child: _NavItem(
                index: 1,
                selectedIndex: _selectedTab,
                icon: Icons.directions_run_rounded,
                label: 'Workout',
                onSelected: _onSelected,
              ),
            ),
            Expanded(
              child: _NavItem(
                index: 2,
                selectedIndex: _selectedTab,
                icon: Icons.history_toggle_off_rounded,
                label: 'History',
                onSelected: _onSelected,
              ),
            ),
            Expanded(
              child: _NavItem(
                index: 3,
                selectedIndex: _selectedTab,
                icon: Icons.settings_rounded,
                label: 'Settings',
                onSelected: _onSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSelected(int index) {
    setState(() => _selectedTab = index);
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.label,
    required this.onSelected,
  });

  final int index;
  final int selectedIndex;
  final IconData icon;
  final String label;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;

    return InkWell(
      onTap: () => onSelected(index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppColors.navUnselected,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? Colors.white : AppColors.navUnselected,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
