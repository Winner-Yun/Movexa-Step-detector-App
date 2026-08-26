import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:step_detector/modules/auth/step_login_page.dart';
import 'package:step_detector/modules/mainapp.dart';
import 'package:step_detector/modules/onboarding/step_onboarding_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          final user = snapshot.data!;
          final creationTime = user.metadata.creationTime;
          final lastSignInTime = user.metadata.lastSignInTime;

          if (creationTime != null && lastSignInTime != null) {
            if (lastSignInTime.difference(creationTime).inSeconds.abs() < 5) {
              return const StepOnboardingPage();
            }
          }

          return const StepMainApp();
        }
        return const StepLoginPage();
      },
    );
  }
}
