import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:step_detector/core/providers/app_providers.dart';
import 'package:step_detector/core/routes/app_routes.dart';
import 'package:step_detector/core/theme/app_theme.dart';
import 'package:step_detector/data/controller/settings_controller.dart';
import 'package:step_detector/modules/auth/auth_wrapper.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders,
      child: Consumer<SettingsController>(
        builder: (context, settingsCtrl, child) {
          final isDark = settingsCtrl.settings.darkModeEnabled;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            home: const AuthWrapper(),
            builder: (context, child) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                  systemNavigationBarColor: Colors.transparent,
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

