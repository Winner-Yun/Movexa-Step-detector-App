import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_detector/core/providers/app_providers.dart';
import 'package:step_detector/core/routes/app_routes.dart';
import 'package:step_detector/core/theme/app_theme.dart';
import 'package:step_detector/modules/auth/auth_wrapper.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const AuthWrapper(),
      ),
    );
  }
}
