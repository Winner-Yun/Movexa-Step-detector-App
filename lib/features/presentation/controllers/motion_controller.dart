import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import 'activity_controller.dart';

enum MotionStatus { idle, walking, stopped, unknown }

const kmPerStep = 0.000762; // ~76cm average stride
const kcalPerStep = 0.04;

// Reads the phone's hardware step counter and streams live step totals
// into ActivityController while the app is running (foreground or
// backgrounded). Start/stop is user-controlled via the tracking toggle.
class MotionController extends ChangeNotifier {
  ActivityController? _activityCtrl;

  StreamSubscription<StepCount>? _stepCountSub;
  StreamSubscription<PedestrianStatus>? _statusSub;

  bool _isTracking = false;
  bool _permissionDenied = false;
  MotionStatus _status = MotionStatus.idle;

  int _dailyGoal = 10000;
  int _alreadyCountedToday = 0; // steps banked before this stream session
  int? _deviceBaselineSteps; // device's cumulative reading when we started
  int _lastDeviceSteps = 0; // used to detect a device reboot mid-session
  int _liveSteps = 0; // steps counted during this stream session

  // Independent workout-session tracking (separate from daily tracking so a
  // workout can be timed even if background tracking is off).
  StreamSubscription<StepCount>? _workoutStepSub;
  bool _isWorkoutActive = false;
  int? _workoutBaselineSteps;
  int _workoutSteps = 0;
  bool _workoutPermissionDenied = false;

  bool get isTracking => _isTracking;
  bool get permissionDenied => _permissionDenied;
  MotionStatus get status => _status;
  int get todaySteps => _alreadyCountedToday + _liveSteps;

  bool get isWorkoutActive => _isWorkoutActive;
  int get workoutSteps => _workoutSteps;
  bool get workoutPermissionDenied => _workoutPermissionDenied;

  void attach(ActivityController activityCtrl) {
    _activityCtrl = activityCtrl;
  }

  Future<bool> _ensurePermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  Future<void> start({required int dailyGoal, int alreadyCountedToday = 0}) async {
    if (_isTracking) return;

    if (!await _ensurePermission()) {
      _permissionDenied = true;
      notifyListeners();
      return;
    }

    _permissionDenied = false;
    _dailyGoal = dailyGoal;
    _alreadyCountedToday = alreadyCountedToday;
    _deviceBaselineSteps = null;
    _lastDeviceSteps = 0;
    _liveSteps = 0;

    _stepCountSub = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: (Object e) => debugPrint('Step count stream error: $e'),
    );
    _statusSub = Pedometer.pedestrianStatusStream.listen(
      _onPedestrianStatus,
      onError: (Object e) => debugPrint('Pedestrian status stream error: $e'),
    );

    _isTracking = true;
    notifyListeners();
  }

  void stop() {
    if (!_isTracking) return;

    _stepCountSub?.cancel();
    _statusSub?.cancel();
    _stepCountSub = null;
    _statusSub = null;

    // Bank whatever this session counted so restarting later resumes
    // from the right total instead of losing progress.
    _alreadyCountedToday += _liveSteps;
    _liveSteps = 0;
    _deviceBaselineSteps = null;

    _isTracking = false;
    _status = MotionStatus.idle;
    notifyListeners();
  }

  Future<bool> startWorkout() async {
    if (_isWorkoutActive) return true;

    if (!await _ensurePermission()) {
      _workoutPermissionDenied = true;
      notifyListeners();
      return false;
    }

    _workoutPermissionDenied = false;
    _workoutBaselineSteps = null;
    _workoutSteps = 0;

    _workoutStepSub = Pedometer.stepCountStream.listen(
      _onWorkoutStepCount,
      onError: (Object e) => debugPrint('Workout step stream error: $e'),
    );

    _isWorkoutActive = true;
    notifyListeners();
    return true;
  }

  int stopWorkout() {
    final finalSteps = _workoutSteps;

    _workoutStepSub?.cancel();
    _workoutStepSub = null;
    _workoutBaselineSteps = null;
    _workoutSteps = 0;
    _isWorkoutActive = false;
    notifyListeners();

    return finalSteps;
  }

  void _onWorkoutStepCount(StepCount event) {
    _workoutBaselineSteps ??= event.steps;
    _workoutSteps = event.steps - _workoutBaselineSteps!;
    notifyListeners();
  }

  void _onStepCount(StepCount event) {
    final deviceSteps = event.steps;

    if (_deviceBaselineSteps == null) {
      _deviceBaselineSteps = deviceSteps;
    } else if (deviceSteps < _lastDeviceSteps) {
      // The device's step counter resets on reboot; bank what we had
      // and start a fresh baseline from the lower reading.
      _alreadyCountedToday += _liveSteps;
      _deviceBaselineSteps = deviceSteps;
    }
    _lastDeviceSteps = deviceSteps;
    _liveSteps = deviceSteps - _deviceBaselineSteps!;

    final totalSteps = todaySteps;
    _activityCtrl?.updateTodaySteps(
      totalSteps,
      _dailyGoal,
      totalSteps * kmPerStep,
      totalSteps * kcalPerStep,
    );

    notifyListeners();
  }

  void _onPedestrianStatus(PedestrianStatus event) {
    _status = switch (event.status) {
      'walking' => MotionStatus.walking,
      'stopped' => MotionStatus.stopped,
      _ => MotionStatus.unknown,
    };
    notifyListeners();
  }

  @override
  void dispose() {
    _stepCountSub?.cancel();
    _statusSub?.cancel();
    _workoutStepSub?.cancel();
    super.dispose();
  }
}
