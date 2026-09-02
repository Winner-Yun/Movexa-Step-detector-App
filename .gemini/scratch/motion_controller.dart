import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:step_detector/core/utils/widget_updater.dart';
import 'package:step_detector/data/controller/activity_controller.dart';

enum MotionStatus { idle, walking, stopped, unknown }

const kmPerStep = 0.000762;
const kcalPerStep = 0.04;

class MotionController extends ChangeNotifier {
  ActivityController? _activityCtrl;

  StreamSubscription<StepCount>? _stepCountSub;
  StreamSubscription<PedestrianStatus>? _statusSub;

  bool _isTracking = false;
  bool _permissionDenied = false;
  MotionStatus _status = MotionStatus.idle;

  int _alreadyCountedToday = 0;
  int? _deviceBaselineSteps;
  int _lastDeviceSteps = 0;
  int _liveSteps = 0;

  StreamSubscription<StepCount>? _workoutStepSub;
  Timer? _workoutTimer;
  int _workoutDurationSeconds = 0;
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
  int get workoutDurationSeconds => _workoutDurationSeconds;
  bool get workoutPermissionDenied => _workoutPermissionDenied;

  String get formattedWorkoutTime {
    final m = (_workoutDurationSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_workoutDurationSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void attach(ActivityController activityCtrl) {
    _activityCtrl = activityCtrl;
  }

  Future<bool> _ensurePermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  Future<void> start({
    required int dailyGoal,
    int alreadyCountedToday = 0,
  }) async {
    if (_isTracking) return;

    if (!await _ensurePermission()) {
      _permissionDenied = true;
      notifyListeners();
      return;
    }

    _permissionDenied = false;
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
    _updateDailyWidget();
  }

  void stop() {
    if (!_isTracking) return;

    _stepCountSub?.cancel();
    _statusSub?.cancel();
    _stepCountSub = null;
    _statusSub = null;

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
    _workoutDurationSeconds = 0;

    _workoutStepSub = Pedometer.stepCountStream.listen(
      _onWorkoutStepCount,
      onError: (Object e) => debugPrint('Workout step stream error: $e'),
    );

    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _workoutDurationSeconds++;
      notifyListeners();
      _updateWorkoutWidget();
    });

    _isWorkoutActive = true;
    notifyListeners();
    _updateWorkoutWidget();
    return true;
  }

  int stopWorkout() {
    final finalSteps = _workoutSteps;

    _workoutStepSub?.cancel();
    _workoutStepSub = null;
    _workoutTimer?.cancel();
    _workoutTimer = null;
    _workoutBaselineSteps = null;
    _workoutSteps = 0;
    _workoutDurationSeconds = 0;
    _isWorkoutActive = false;
    notifyListeners();

    _updateDailyWidget();
    return finalSteps;
  }

  void _onWorkoutStepCount(StepCount event) {
    _workoutBaselineSteps ??= event.steps;
    _workoutSteps = event.steps - _workoutBaselineSteps!;
    notifyListeners();
    _updateWorkoutWidget();
  }

  void _onStepCount(StepCount event) {
    final deviceSteps = event.steps;

    if (_deviceBaselineSteps == null) {
      _deviceBaselineSteps = deviceSteps;
    } else if (deviceSteps < _lastDeviceSteps) {
      _alreadyCountedToday += _liveSteps;
      _deviceBaselineSteps = deviceSteps;
    }
    _lastDeviceSteps = deviceSteps;
    _liveSteps = deviceSteps - _deviceBaselineSteps!;

    final totalSteps = todaySteps;
    _activityCtrl?.updateTodaySteps(
      totalSteps,
      totalSteps * kmPerStep,
      totalSteps * kcalPerStep,
    );

    notifyListeners();
    if (!_isWorkoutActive) {
      _updateDailyWidget();
    }
  }

  void _onPedestrianStatus(PedestrianStatus event) {
    _status = switch (event.status) {
      'walking' => MotionStatus.walking,
      'stopped' => MotionStatus.stopped,
      _ => MotionStatus.unknown,
    };
    notifyListeners();
  }

  void _updateDailyWidget() {
    final totalSteps = todaySteps;
    WidgetUpdater.updateDailyStats(
      steps: totalSteps,
      cal: totalSteps * kcalPerStep,
      km: totalSteps * kmPerStep,
    );
  }

  void _updateWorkoutWidget() {
    final speed = _workoutDurationSeconds > 0 
      ? ((_workoutSteps * kmPerStep) / (_workoutDurationSeconds / 3600))
      : 0.0;

    WidgetUpdater.updateWorkoutStats(
      time: formattedWorkoutTime,
      steps: _workoutSteps,
      cal: _workoutSteps * kcalPerStep,
      km: _workoutSteps * kmPerStep,
      speed: speed,
    );
  }

  @override
  void dispose() {
    _stepCountSub?.cancel();
    _statusSub?.cancel();
    _workoutStepSub?.cancel();
    _workoutTimer?.cancel();
    super.dispose();
  }
}
