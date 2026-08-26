import 'package:flutter/material.dart';
import 'package:step_detector/core/routes/route_names.dart';
import 'package:step_detector/modules/auth/step_login_page.dart';
import 'package:step_detector/modules/mainapp.dart';
import 'package:step_detector/modules/onboarding/step_onboarding_page.dart';

class AppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const StepLoginPage());
      case RouteNames.onboarding:
        return MaterialPageRoute(builder: (_) => const StepOnboardingPage());
      case RouteNames.mainApp:
        return MaterialPageRoute(builder: (_) => const StepMainApp());
      default:
        return null;
    }
  }
}
