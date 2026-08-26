import 'package:firebase_auth/firebase_auth.dart'; // Add this
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:step_detector/features/presentation/auth/step_login_page.dart';
import 'package:step_detector/features/presentation/controllers/activity_controller.dart';
import 'package:step_detector/features/presentation/controllers/auth_controller.dart';
import 'package:step_detector/features/presentation/controllers/motion_controller.dart';
import 'package:step_detector/features/presentation/controllers/profile_controller.dart';
import 'package:step_detector/features/presentation/controllers/settings_controller.dart';
import 'package:step_detector/features/presentation/mainapp.dart';

import 'config/firebase_options.dart';
import 'core/constants/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()), // ADDED THIS
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => ActivityController()),
        ChangeNotifierProxyProvider<ActivityController, MotionController>(
          create: (_) => MotionController(),
          update: (_, activityCtrl, motionCtrl) =>
              motionCtrl!..attach(activityCtrl),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.scaffoldSoft,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryYellow,
          primary: AppColors.primaryYellow,
          onPrimary: AppColors.darkText,
          surface: AppColors.surface,
          onSurface: AppColors.darkText,
        ),
        textTheme:
            GoogleFonts.kantumruyProTextTheme(
              Theme.of(context).textTheme,
            ).copyWith(
              headlineSmall: GoogleFonts.nokora(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
              displaySmall: GoogleFonts.nokora(
                fontSize: 46,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
              titleMedium: GoogleFonts.nokora(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              bodyMedium: GoogleFonts.nokora(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
      ),
      // THE MAGIC GATEKEEPER
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If Firebase is checking...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // If User is logged in, show Dashboard
          if (snapshot.hasData) {
            return const StepMainApp();
          }
          // If User is NOT logged in, show Login Page
          return const StepLoginPage();
        },
      ),
    );
  }
}
