import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_detector/core/constants/app_img.dart';
import 'package:step_detector/core/localization/app_translations.dart';
import 'package:step_detector/core/theme/theme_colors.dart';
import 'package:step_detector/data/controller/auth_controller.dart';

class StepLoginPage extends StatefulWidget {
  const StepLoginPage({super.key});

  @override
  State<StepLoginPage> createState() => _StepLoginPageState();
}

class _StepLoginPageState extends State<StepLoginPage> {
  void _handleGoogleSignIn() async {
    final authCtrl = context.read<AuthController>();
    final error = await authCtrl.signInWithGoogle();

    if (error != null && mounted) {
      _showSnack(error);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isLoading = context.watch<AuthController>().isLoading;
    final locale = context.watch<AppTranslations>().locale;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  // Logo
                  Image.asset(
                    AppImg.logo,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  const Spacer(flex: 1),
                  // Title
                  Text(
                    'appSlogan'.tr(context),
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall?.copyWith(
                      color: ThemeColors.getText(context),
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Continue with Google Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _handleGoogleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.getBrandAccent(context),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 0,
                      ),
                      icon: isLoading
                          ? const SizedBox.shrink()
                          : const Icon(
                              Icons.g_mobiledata_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                      label: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              'continueWithGoogle'.tr(context),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),

            // Language Changer top right
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: ThemeColors.getBrandAccent(
                    context,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLangBtn(
                      context,
                      'EN',
                      'en',
                      locale.languageCode == 'en',
                    ),
                    _buildLangBtn(
                      context,
                      'KM',
                      'km',
                      locale.languageCode == 'km',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangBtn(
    BuildContext context,
    String text,
    String langCode,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<AppTranslations>().changeLocale(Locale(langCode));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeColors.getBrandAccent(context)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : ThemeColors.getText(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
