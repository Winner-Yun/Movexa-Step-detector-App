import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:step_detector/core/constants/app_colors.dart';
import 'package:step_detector/data/controller/auth_controller.dart';
import 'package:step_detector/data/controller/motion_controller.dart';
import 'package:step_detector/data/controller/profile_controller.dart';
import 'package:step_detector/data/controller/settings_controller.dart';
import 'package:step_detector/modules/profile/step_profile_edit_page.dart';

class StepSettingsPage extends StatefulWidget {
  const StepSettingsPage({super.key});

  @override
  State<StepSettingsPage> createState() => _StepSettingsPageState();
}

class _StepSettingsPageState extends State<StepSettingsPage> {
  final TextEditingController _goalInputController = TextEditingController();

  void _showSetGoalDialog(SettingsController settingsCtrl) {
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
                    _buildGoalDialogHeader(),
                    const SizedBox(height: 24),
                    _buildGoalInput(errorMessage, setState),
                    const SizedBox(height: 28),
                    _buildGoalDialogActions(context, setState, settingsCtrl),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGoalDialogHeader() {
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

  Widget _buildGoalInput(String? errorMessage, StateSetter setState) {
    return TextField(
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
        hintText: '10000',
        hintStyle: TextStyle(
          color: AppColors.brandAccent.withValues(alpha: 0.3),
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: AppColors.scaffoldSoft,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildGoalDialogActions(
    BuildContext context,
    StateSetter setState,
    SettingsController settingsCtrl,
  ) {
    return Row(
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
              final newGoal = int.tryParse(_goalInputController.text);
              if (newGoal != null && newGoal > 0) {
                settingsCtrl.updateStepGoal(newGoal);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('បានកំណត់គោលដៅថ្មី: $newGoal')),
                );
                Navigator.pop(context);
                _goalInputController.clear();
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
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
          backgroundColor: AppColors.surface,
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
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ចាកចេញពីគណនី?',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'តើអ្នកពិតជាចង់ចាកចេញពីគណនីមែនទេ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.mutedText, fontSize: 14),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'បោះបង់',
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                        child: const Text(
                          'ចាកចេញ',
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final profileCtrl = context.watch<ProfileController>();
    final settingsCtrl = context.watch<SettingsController>();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brandAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: AppColors.brandAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'ការកំណត់',
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: false,
        toolbarHeight: 64,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildProfileCard(textTheme, profileCtrl),
              const SizedBox(height: 32),

              _buildSectionTitle('គណនី (Account)', textTheme),
              _buildSettingsGroup([
                _buildSettingsTile(
                  Icons.person_outline_rounded,
                  'ព័ត៌មានផ្ទាល់ខ្លួន',
                  onTap: _navigateToProfileEdit,
                ),
                _buildSettingsTile(
                  Icons.flag_outlined,
                  'គោលដៅជំហាន',
                  trailingText: '${settingsCtrl.settings.dailyStepGoal}',
                  onTap: () => _showSetGoalDialog(settingsCtrl),
                ),
              ]),
              const SizedBox(height: 24),

              _buildSectionTitle('ចំណូលចិត្ត (Preferences)', textTheme),
              _buildSettingsGroup([
                _buildSettingsTile(
                  Icons.notifications_none_rounded,
                  'ការជូនដំណឹង',
                  isSwitch: true,
                  switchValue: settingsCtrl.settings.notificationsEnabled,
                  onSwitchChanged: (val) => settingsCtrl.updateSettings(
                    settingsCtrl.settings.copyWith(notificationsEnabled: val),
                  ),
                ),
              ]),

              const SizedBox(height: 40),
              Center(
                child: TextButton.icon(
                  onPressed: _showLogoutDialog,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    'ចាកចេញ (Log Out)',
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
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryGradientStart,
            AppColors.primaryGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandAccent.withValues(alpha: 0.3),
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
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.brandAccent,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
                Text(
                  bio,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _navigateToProfileEdit,
            icon: const Icon(Icons.edit_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
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
          color: AppColors.mutedText,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withValues(alpha: 0.03),
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(color: AppColors.scaffoldSoft, height: 1),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title, {
    String? trailingText,
    bool isSwitch = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isSwitch ? () => onSwitchChanged?.call(!switchValue) : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.scaffoldSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.brandAccent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (isSwitch)
              Switch.adaptive(
                value: switchValue,
                activeColor: AppColors.brandAccent,
                activeTrackColor: AppColors.brandAccent.withValues(alpha: 0.3),
                onChanged: onSwitchChanged,
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.mutedText,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
