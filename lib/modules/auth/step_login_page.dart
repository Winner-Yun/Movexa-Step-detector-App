import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ThemeColors.getPrimaryGradientStart(context),
                    ThemeColors.getPrimaryGradientEnd(context),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ThemeColors.getBrandAccent(
                      context,
                    ).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.directions_run_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Kinetic',
                      style: textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'trackingSteps'.tr(context),
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'loginTitle'.tr(context),
                    style: textTheme.headlineSmall?.copyWith(
                      color: ThemeColors.getText(context),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'loginWithGoogleSubtitle'.tr(context),
                    style: textTheme.bodyMedium?.copyWith(
                      color: ThemeColors.getMutedText(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 40),

                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.getBrandAccent(context),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    icon: isLoading
                        ? const SizedBox.shrink()
                        : Icon(
                            Icons.g_mobiledata_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                    label: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'loginWithGoogle'.tr(context),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
