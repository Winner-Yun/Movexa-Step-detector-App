import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:step_detector/core/localization/app_translations.dart';
import 'package:step_detector/data/controller/activity_controller.dart';
import 'package:step_detector/data/controller/auth_controller.dart';
import 'package:step_detector/data/controller/motion_controller.dart';
import 'package:step_detector/data/controller/profile_controller.dart';
import 'package:step_detector/data/controller/settings_controller.dart';

final List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider(create: (_) => AuthController()),
  ChangeNotifierProvider(create: (_) => ProfileController()),
  ChangeNotifierProvider(create: (_) => SettingsController()),
  ChangeNotifierProxyProvider<SettingsController, AppTranslations>(
    create: (_) => AppTranslations(),
    update: (_, settingsCtrl, appTranslations) =>
        appTranslations!..changeLocale(Locale(settingsCtrl.settings.language)),
  ),
  ChangeNotifierProvider(create: (_) => ActivityController()),
  ChangeNotifierProxyProvider<ActivityController, MotionController>(
    create: (_) => MotionController(),
    update: (_, activityCtrl, motionCtrl) => motionCtrl!..attach(activityCtrl),
  ),
];
