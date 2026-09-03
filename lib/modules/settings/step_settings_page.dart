import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_detector/core/localization/app_translations.dart';
import 'package:step_detector/core/theme/theme_colors.dart';
import 'package:step_detector/data/controller/activity_controller.dart';
import 'package:step_detector/data/controller/auth_controller.dart';
import 'package:step_detector/data/controller/motion_controller.dart';
import 'package:step_detector/data/controller/profile_controller.dart';
import 'package:step_detector/data/controller/settings_controller.dart';
import 'package:step_detector/modules/profile/step_profile_edit_page.dart';
import 'package:step_detector/modules/settings/about_us_page.dart';
import 'package:step_detector/widgets/set_goal_dialog.dart';
import 'package:step_detector/widgets/skeleton.dart';

class StepSettingsPage extends StatefulWidget {
  const StepSettingsPage({super.key});

  @override
  State<StepSettingsPage> createState() => _StepSettingsPageState();
}

class _StepSettingsPageState extends State<StepSettingsPage> {
  void _showSetGoalDialog(SettingsController settingsCtrl) {
    showDialog(
      context: context,
      builder: (context) {
        return SetGoalDialog(
          currentGoal: settingsCtrl.settings.dailyStepGoal,
          onGoalChanged: (newGoal) {
            settingsCtrl.updateStepGoal(newGoal);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${context.read<AppTranslations>().tr('newGoalSet')}$newGoal',
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToProfileEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StepProfileEditPage()),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
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
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 32,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'logoutAccount'.tr(context),
                  style: TextStyle(
                    color: ThemeColors.getText(context),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'confirmLogout'.tr(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ThemeColors.getMutedText(context),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'cancel'.tr(context),
                          style: TextStyle(
                            color: ThemeColors.getMutedText(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          context.read<MotionController>().stop();
                          await context.read<AuthController>().logout();
                          if (navigator.mounted) {
                            navigator.pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'logout'.tr(context),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
  }

  void _showMapSettingsDialog(SettingsController settingsCtrl) {
    double currentLineSize = settingsCtrl.settings.mapLineSize;
    double currentMarkerSize = settingsCtrl.settings.mapMarkerSize;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    Text(
                      'Map Settings',
                      style: TextStyle(
                        color: ThemeColors.getText(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Line Size: ${currentLineSize.toInt()}',
                          style: TextStyle(
                            color: ThemeColors.getText(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: currentLineSize,
                      min: 1,
                      max: 20,
                      divisions: 19,
                      activeColor: ThemeColors.getBrandAccent(context),
                      inactiveColor: ThemeColors.getScaffoldSoft(context),
                      onChanged: (val) {
                        setState(() {
                          currentLineSize = val;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Marker Size: ${currentMarkerSize.toInt()}',
                          style: TextStyle(
                            color: ThemeColors.getText(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: currentMarkerSize,
                      min: 10,
                      max: 50,
                      divisions: 40,
                      activeColor: ThemeColors.getBrandAccent(context),
                      inactiveColor: ThemeColors.getScaffoldSoft(context),
                      onChanged: (val) {
                        setState(() {
                          currentMarkerSize = val;
                        });
                      },
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'cancel'.tr(context),
                            style: TextStyle(
                              color: ThemeColors.getMutedText(context),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            settingsCtrl.updateSettings(
                              settingsCtrl.settings.copyWith(
                                mapLineSize: currentLineSize,
                                mapMarkerSize: currentMarkerSize,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.getBrandAccent(
                              context,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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

  Future<void> _onRefresh(BuildContext context) async {
    final activityCtrl = context.read<ActivityController>();
    final profileCtrl = context.read<ProfileController>();
    final settingsCtrl = context.read<SettingsController>();

    if (activityCtrl.isFetching) return;

    activityCtrl.setFetching(true);

    await Future.wait([
      profileCtrl.fetchProfile(),
      settingsCtrl.fetchSettings(),
      activityCtrl.fetchTodayRecord(
        dailyGoal: settingsCtrl.settings.dailyStepGoal,
      ),
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColors.getScaffold(context),
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ThemeColors.getBrandAccent(
                  context,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.settings_rounded,
                color: ThemeColors.getBrandAccent(context),
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'settings'.tr(context),
              style: textTheme.titleLarge?.copyWith(
                color: ThemeColors.getText(context),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        centerTitle: false,
        toolbarHeight: 64,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _onRefresh(context),
          color: ThemeColors.getBrandAccent(context),
          backgroundColor: ThemeColors.getSurface(context),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child:
                profileCtrl.isLoading ||
                    context.watch<ActivityController>().isFetching
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    children: const [ProfileSkeleton()],
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24),
                        _buildProfileCard(textTheme, profileCtrl),
                        SizedBox(height: 32),

                        _buildSectionTitle('account'.tr(context), textTheme),
                        _buildSettingsGroup([
                          _SettingsItemTile(
                            context: context,
                            icon: Icons.person_outline_rounded,
                            title: 'personalInfo'.tr(context),
                            onTap: _navigateToProfileEdit,
                          ),
                          _SettingsItemTile(
                            context: context,
                            icon: Icons.flag_outlined,
                            title: 'stepGoal'.tr(context),
                            trailingText:
                                '${settingsCtrl.settings.dailyStepGoal}',
                            onTap: () => _showSetGoalDialog(settingsCtrl),
                          ),
                        ]),

                        SizedBox(height: 24),

                        _buildSectionTitle(
                          'preferences'.tr(context),
                          textTheme,
                        ),
                        _buildSettingsGroup([
                          _SettingsItemTile(
                            context: context,
                            icon: Icons.dark_mode_outlined,
                            title: 'darkMode'.tr(context),
                            isSwitch: true,
                            switchValue: settingsCtrl.settings.darkModeEnabled,
                            onSwitchChanged: (val) =>
                                settingsCtrl.updateSettings(
                                  settingsCtrl.settings.copyWith(
                                    darkModeEnabled: val,
                                  ),
                                ),
                          ),
                          _SettingsItemTile(
                            context: context,
                            icon: Icons.language_rounded,
                            title: 'language'.tr(context),
                            trailingText: settingsCtrl.settings.language == 'km'
                                ? 'ខ្មែរ'
                                : 'English',
                            isSwitch: true,
                            switchValue: settingsCtrl.settings.language == 'km',
                            onSwitchChanged: (val) {
                              final newLang = val ? 'km' : 'en';
                              settingsCtrl.updateSettings(
                                settingsCtrl.settings.copyWith(
                                  language: newLang,
                                ),
                              );
                            },
                          ),
                          _SettingsItemTile(
                            context: context,
                            icon: Icons.track_changes_rounded,
                            title: 'dailyTrackRecord'.tr(context),
                            isSwitch: true,
                            switchValue:
                                settingsCtrl.settings.runTrackingInBackground,
                            onSwitchChanged: (val) async {
                              final activityCtrl = context
                                  .read<ActivityController>();
                              final motionCtrl = context
                                  .read<MotionController>();

                              final newSettings = settingsCtrl.settings
                                  .copyWith(runTrackingInBackground: val);
                              settingsCtrl.updateSettings(newSettings);

                              if (val) {
                                await motionCtrl.start(
                                  dailyGoal:
                                      settingsCtrl.settings.dailyStepGoal,
                                  alreadyCountedToday:
                                      activityCtrl.todayRecord?.steps ?? 0,
                                  runInBackground: val,
                                );
                                if (motionCtrl.permissionDenied) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.read<AppTranslations>().tr(
                                          'motionPermissionRequired',
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                motionCtrl.stop();
                                final steps = motionCtrl.todaySteps;
                                final distance =
                                    (steps * MotionController.kmPerStep)
                                        .toDouble();
                                final calories =
                                    (steps * MotionController.kcalPerStep)
                                        .toDouble();
                                await activityCtrl.updateTodaySteps(
                                  steps,
                                  distance,
                                  calories,
                                );
                              }
                            },
                          ),
                          _SettingsItemTile(
                            context: context,
                            icon: Icons.map_rounded,
                            title: 'Map Settings',
                            onTap: () => _showMapSettingsDialog(settingsCtrl),
                          ),
                          _SettingsItemTile(
                            context: context,
                            icon: Icons.info_outline_rounded,
                            title: 'aboutUs'.tr(context),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutUsPage(),
                                ),
                              );
                            },
                          ),
                        ]),

                        SizedBox(height: 40),
                        Center(
                          child: TextButton.icon(
                            onPressed: _showLogoutDialog,
                            icon: Icon(
                              Icons.logout_rounded,
                              color: Colors.redAccent,
                            ),
                            label: Text(
                              'logoutAction'.tr(context),
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(TextTheme textTheme, ProfileController profileCtrl) {
    final profile = profileCtrl.currentProfile;
    final name = profile?.name ?? '';
    final bio = profile?.bio ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getPrimaryGradientStart(context),
            ThemeColors.getPrimaryGradientEnd(context),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getBrandAccent(context).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 3,
              ),
              image:
                  (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(profile.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (profile?.avatarUrl == null || profile!.avatarUrl!.isEmpty)
                ? Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: ThemeColors.getBrandAccent(context),
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  bio,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                if (profile != null &&
                    (profile.age > 0 ||
                        profile.weight > 0 ||
                        profile.height > 0)) ...[
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (profile.age > 0)
                        _buildProfileStatBadge(
                          context,
                          Icons.cake_rounded,
                          '${profile.age}',
                        ),
                      if (profile.weight > 0)
                        _buildProfileStatBadge(
                          context,
                          Icons.monitor_weight_rounded,
                          '${profile.weight} kg',
                        ),
                      if (profile.height > 0)
                        _buildProfileStatBadge(
                          context,
                          Icons.height_rounded,
                          '${profile.height} cm',
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: _navigateToProfileEdit,
            icon: Icon(Icons.edit_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatBadge(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: textTheme.titleSmall?.copyWith(
          color: ThemeColors.getMutedText(context),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getText(context).withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final int index = entry.key;
          final Widget child = entry.value;
          if (index == children.length - 1) return child;
          return Column(
            children: [
              child,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  color: ThemeColors.getScaffoldSoft(context),
                  height: 1,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsItemTile extends StatefulWidget {
  final BuildContext context;
  final IconData icon;
  final String title;
  final String? trailingText;
  final bool isSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback? onTap;

  const _SettingsItemTile({
    required this.context,
    required this.icon,
    required this.title,
    this.trailingText,
    this.isSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
    this.onTap,
  });

  @override
  State<_SettingsItemTile> createState() => _SettingsItemTileState();
}

class _SettingsItemTileState extends State<_SettingsItemTile> {
  late bool _localSwitchValue;

  @override
  void initState() {
    super.initState();
    _localSwitchValue = widget.switchValue;
  }

  @override
  void didUpdateWidget(_SettingsItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.switchValue != widget.switchValue) {
      _localSwitchValue = widget.switchValue;
    }
  }

  void _handleTap() {
    if (widget.isSwitch) {
      setState(() {
        _localSwitchValue = !_localSwitchValue;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          widget.onSwitchChanged?.call(_localSwitchValue);
        }
      });
    } else {
      widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ThemeColors.getScaffoldSoft(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                color: ThemeColors.getBrandAccent(context),
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
            ),
            if (widget.trailingText != null) ...[
              Text(
                widget.trailingText!,
                style: TextStyle(
                  color: ThemeColors.getMutedText(context),
                  fontWeight: FontWeight.w200,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 8),
            ],
            if (widget.isSwitch)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutBack,
                width: 52,
                height: 30,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _localSwitchValue
                      ? ThemeColors.getPrimaryGradientStart(context)
                      : ThemeColors.getMutedText(
                          context,
                        ).withValues(alpha: 0.2),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutBack,
                  alignment: _localSwitchValue
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: ThemeColors.getMutedText(context),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
