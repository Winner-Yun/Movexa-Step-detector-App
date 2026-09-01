import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_detector/core/utils/widget_updater.dart';

const kmPerStep = 0.000762;
const kcalPerStep = 0.04;

@pragma('vm:entry-point')
void startCallback() {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  FlutterForegroundTask.setTaskHandler(BackgroundStepHandler());
}

class BackgroundStepHandler extends TaskHandler {
  StreamSubscription<StepCount>? _stepCountSub;
  int? _deviceBaselineSteps;
  int _alreadyCountedToday = 0;
  int _lastDeviceSteps = 0;
  int _liveSteps = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final prefs = await SharedPreferences.getInstance();
    _alreadyCountedToday = prefs.getInt('bg_alreadyCountedToday') ?? 0;
    _lastDeviceSteps = prefs.getInt('bg_lastDeviceSteps') ?? 0;

    _stepCountSub = Pedometer.stepCountStream.listen(
      (StepCount event) async {
        final deviceSteps = event.steps;

        if (_deviceBaselineSteps == null) {
          _deviceBaselineSteps = deviceSteps;
        } else if (deviceSteps < _lastDeviceSteps) {
          // Device rebooted or counter reset
          _alreadyCountedToday += _liveSteps;
          _deviceBaselineSteps = deviceSteps;
        }

        _lastDeviceSteps = deviceSteps;
        _liveSteps = deviceSteps - _deviceBaselineSteps!;

        final totalSteps = _alreadyCountedToday + _liveSteps;

        // Save state continuously so we don't lose steps on force-kill
        await prefs.setInt('bg_alreadyCountedToday', totalSteps);
        await prefs.setInt('bg_lastDeviceSteps', deviceSteps);

        final isWorkoutActive = prefs.getBool('workoutIsActive') ?? false;

        if (isWorkoutActive) {
          final startTimeStr = prefs.getString('workoutStartTime');
          final baselineSteps = prefs.getInt('workoutBaselineSteps');

          if (startTimeStr != null && baselineSteps != null) {
            final startTime = DateTime.parse(startTimeStr);
            final durationSeconds = DateTime.now()
                .difference(startTime)
                .inSeconds;

            var workoutSteps = deviceSteps - baselineSteps;
            if (workoutSteps < 0) workoutSteps = 0; // fallback if rebooted

            final minutes = (durationSeconds ~/ 60).toString().padLeft(2, '0');
            final seconds = (durationSeconds % 60).toString().padLeft(2, '0');
            final formattedTime = '$minutes:$seconds';

            final speed = durationSeconds > 0
                ? ((workoutSteps * kmPerStep) / (durationSeconds / 3600.0))
                : 0.0;

            await WidgetUpdater.updateWorkoutStats(
              time: formattedTime,
              steps: workoutSteps,
              cal: workoutSteps * kcalPerStep,
              km: workoutSteps * kmPerStep,
              speed: speed,
            );

            FlutterForegroundTask.updateService(
              notificationTitle: 'Workout Active',
              notificationText: 'Time: $formattedTime | Steps: $workoutSteps',
              notificationButtons: [
                const NotificationButton(
                  id: 'close_app',
                  text: 'Stop Tracking',
                ),
              ],
            );
          }
        } else {
          // Update the home widget from the background!
          await WidgetUpdater.updateDailyStats(
            steps: totalSteps,
            cal: totalSteps * kcalPerStep,
            km: totalSteps * kmPerStep,
          );

          // Optionally update notification
          FlutterForegroundTask.updateService(
            notificationTitle: 'Tracking Steps',
            notificationText: '$totalSteps steps today',
            notificationButtons: [
              const NotificationButton(id: 'close_app', text: 'Stop Tracking'),
            ],
          );
        }

        // Send data to the main UI isolate if it's running
        FlutterForegroundTask.sendDataToMain(totalSteps);
      },
      onError: (Object e) {
        debugPrint('Background Pedometer error: $e');
      },
    );
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    final isWorkoutActive = prefs.getBool('workoutIsActive') ?? false;

    if (isWorkoutActive) {
      final startTimeStr = prefs.getString('workoutStartTime');
      final baselineSteps = prefs.getInt('workoutBaselineSteps');

      if (startTimeStr != null && baselineSteps != null) {
        final startTime = DateTime.parse(startTimeStr);
        final durationSeconds = DateTime.now().difference(startTime).inSeconds;

        // If pedometer hasn't fired yet, fallback to 0
        final currentDeviceSteps = _lastDeviceSteps > 0
            ? _lastDeviceSteps
            : baselineSteps;
        var workoutSteps = currentDeviceSteps - baselineSteps;
        if (workoutSteps < 0) workoutSteps = 0;

        final minutes = (durationSeconds ~/ 60).toString().padLeft(2, '0');
        final seconds = (durationSeconds % 60).toString().padLeft(2, '0');
        final formattedTime = '$minutes:$seconds';

        final speed = durationSeconds > 0
            ? ((workoutSteps * kmPerStep) / (durationSeconds / 3600.0))
            : 0.0;

        await WidgetUpdater.updateWorkoutStats(
          time: formattedTime,
          steps: workoutSteps,
          cal: workoutSteps * kcalPerStep,
          km: workoutSteps * kmPerStep,
          speed: speed,
        );

        FlutterForegroundTask.updateService(
          notificationTitle: 'Workout Active',
          notificationText: 'Time: $formattedTime | Steps: $workoutSteps',
          notificationButtons: [
            const NotificationButton(id: 'close_app', text: 'Stop Tracking'),
          ],
        );
      }
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _stepCountSub?.cancel();

    // Save state before getting destroyed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'bg_alreadyCountedToday',
      _alreadyCountedToday + _liveSteps,
    );
    if (_lastDeviceSteps > 0) {
      await prefs.setInt('bg_lastDeviceSteps', _lastDeviceSteps);
    }
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'close_app') {
      FlutterForegroundTask.sendDataToMain('stop_service');
      FlutterForegroundTask.stopService();
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }
}
