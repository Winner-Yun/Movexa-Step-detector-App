import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_detector/core/theme/theme_colors.dart';
import 'package:step_detector/data/controller/profile_controller.dart';
import 'package:step_detector/core/localization/app_translations.dart';

class StepProfileEditPage extends StatefulWidget {
  const StepProfileEditPage({super.key});
  @override
  State<StepProfileEditPage> createState() => _StepProfileEditPageState();
}

class _StepProfileEditPageState extends State<StepProfileEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileController>().currentProfile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _ageController = TextEditingController(text: profile?.age.toString() ?? '');
    _weightController = TextEditingController(
      text: profile?.weight.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: profile?.height.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final profileCtrl = context.read<ProfileController>();
    final currentProfile = profileCtrl.currentProfile;
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(
      name: _nameController.text,
      bio: _bioController.text,
      age: int.tryParse(_ageController.text) ?? currentProfile.age,
      weight: double.tryParse(_weightController.text) ?? currentProfile.weight,
      height: double.tryParse(_heightController.text) ?? currentProfile.height,
    );

    final success = await profileCtrl.saveProfile(updatedProfile);

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('savedSuccessfully'.tr(context))));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<ProfileController>().isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColors.getPrimaryGradientStart(context),
        elevation: 0,
        title: Text(
          'editProfile'.tr(context),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildPremiumInputField(
              'name'.tr(context),
              Icons.person_rounded,
              _nameController,
            ),
            SizedBox(height: 16),
            _buildPremiumInputField(
              'aboutMe'.tr(context),
              Icons.info_rounded,
              _bioController,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPremiumInputField(
                    'age'.tr(context),
                    Icons.cake_rounded,
                    _ageController,
                    isNumber: true,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildPremiumInputField(
                    'weight'.tr(context),
                    Icons.monitor_weight_rounded,
                    _weightController,
                    isNumber: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.getBrandAccent(context),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'save'.tr(context),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumInputField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: ThemeColors.getBrandAccent(context)),
        labelText: hint,
        filled: true,
        fillColor: ThemeColors.getSurface(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
