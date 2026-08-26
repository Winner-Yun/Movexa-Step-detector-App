import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:step_detector/core/constants/app_colors.dart';
import 'package:step_detector/core/localization/app_translations.dart';
import 'package:step_detector/data/controller/auth_controller.dart';
import 'package:step_detector/modules/mainapp.dart';

class StepOnboardingPage extends StatelessWidget {
  const StepOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('welcomeMessage'.tr(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthController>().logout();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.fitness_center, size: 80, color: AppColors.primaryYellow),
            const SizedBox(height: 24),
            Text(
              'welcomeMessage'.tr(context),
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'onboardingDesc'.tr(context),
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const StepMainApp()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text('continueToApp'.tr(context), style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
