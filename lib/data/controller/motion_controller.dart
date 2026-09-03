import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_detector/core/utils/widget_updater.dart';
import 'package:step_detector/data/controller/activity_controller.dart';
import 'package:step_detector/data/controller/background_service_handler.dart';
import 'package:step_detector/data/local/database_helper.dart';
import 'package:intl/intl.dart';

enum MotionStatus { idle, walking, stopped, unknown }

class MotionController extends ChangeNotifier {
  static const double kmPerStep = 0.000762;
  static const double kcalPerStep = 0.04;

  ActivityController? _activityCtrl;

  StreamSubscription<StepCount>? _stepCountSub;
  StreamSubscription<PedestrianStatus>? _statusSub;
  StreamSubscription<Position>? _positionSub;

  Position? _latestPosition;

  List<Map<String, dynamic>> _dailyPath = [];
  List<Map<String, dynamic>> _workoutPath = [];

  List<Map<String, dynamic>> get dailyPath => _dailyPath;
  List<Map<String, dynamic>> get workoutPath => _workoutPath;

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

  bool _runInBackground = false;
  String? _currentDayStr;

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

  VoidCallback? onServiceStoppedExternally;

  void attach(ActivityController activityCtrl) {
    _activityCtrl = activityCtrl;
  }

  void _checkNewDay() {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (_currentDayStr != null && _currentDayStr != todayStr) {
      _currentDayStr = todayStr;
      _dailyPath.clear();
      _alreadyCountedToday = 0;
      _liveSteps = 0;
      _deviceBaselineSteps = _lastDeviceSteps;
      _activityCtrl?.fetchTodayRecord();
    }
  }

  void _addPointToPath(Map<String, dynamic> point, List<Map<String, dynamic>> path) {
    if (path.isEmpty) {
      path.add(point);
      return;
    }
    
    if (path.last['gap'] == true) {
      path.add(point);
      return;
    }
    
    final lastPoint = path.last;
    if (lastPoint['lat'] == point['lat'] && lastPoint['lng'] == point['lng']) {
      return; 
    }
    
    final lastTs = lastPoint['ts'] as int?;
    final currentTs = point['ts'] as int?;

    if (lastTs != null && currentTs != null) {
      final diffSeconds = (currentTs - lastTs) / 1000;
      if (diffSeconds >= 60) {
        path.add({'gap': true});
      }
    }
    
    path.add(point);
  }

  Future<bool> _ensurePermission() async {
    bool hasLocation = false;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      hasLocation = true;
    }

    if (!Platform.isAndroid) return hasLocation;
    final status = await Permission.activityRecognition.request();
    // Also request notification permission for Android 13+
    await Permission.notification.request();
    return status.isGranted && hasLocation;
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'step_counter',
        channelName: 'Step Counter',
        channelDescription: 'Keeps the step counter running in background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
        stopWithTask: false,
      ),
    );
  }

  Future<void> start({
    required int dailyGoal,
    int alreadyCountedToday = 0,
    bool? runInBackground,
  }) async {
    if (_isTracking) return;

    if (!await _ensurePermission()) {
      _permissionDenied = true;
      notifyListeners();
      return;
    }

    if (runInBackground != null) {
      _runInBackground = runInBackground;
    } else {
      // Check settings for background tracking
      final bgSetting = await DatabaseHelper.instance.getSetting(
        'runTrackingInBackground',
      );
      _runInBackground =
          bgSetting == 'true' || bgSetting == null; // Default true
    }

    _permissionDenied = false;
    _alreadyCountedToday = alreadyCountedToday;
    _deviceBaselineSteps = null;
    _lastDeviceSteps = 0;
    _liveSteps = 0;
    _isTracking = true;
    _currentDayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (_runInBackground && Platform.isAndroid) {
      _initForegroundTask();
      final isRunning = await FlutterForegroundTask.isRunningService;
      if (!isRunning) {
        await FlutterForegroundTask.startService(
          notificationTitle: 'Movexa Step Tracker',
          notificationText: 'Tracking steps in background',
          notificationButtons: [
            const NotificationButton(id: 'close_app', text: 'Stop Tracking'),
          ],
          callback: startCallback,
        );
      }

      FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    } else {
      // Local tracking only
      _stepCountSub = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: (Object e) => debugPrint('Step count stream error: $e'),
      );
    }

    _statusSub = Pedometer.pedestrianStatusStream.listen(
      _onPedestrianStatus,
      onError: (Object e) => debugPrint('Pedestrian status stream error: $e'),
    );

    _dailyPath = List.from(_activityCtrl?.todayRecord?.path ?? []);
    
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _latestPosition = position;
    }, onError: (e) => debugPrint('Location error: $e'));

    notifyListeners();
    _updateDailyWidget();
  }

  void _onReceiveTaskData(Object message) {
    if (message is int) {
      _updateFromBackground(message);
    } else if (message == 'stop_service') {
      stop();
      onServiceStoppedExternally?.call();
    }
  }

  void _updateFromBackground(int totalSteps) {
    // Background task handles baseline and live steps, it just sends us the total.
    // We update local state so the UI reflects it.
    _alreadyCountedToday = totalSteps;
    _liveSteps = 0; // live steps handled by background

    _checkNewDay();

    if (_latestPosition != null) {
      final point = {
        'lat': _latestPosition!.latitude,
        'lng': _latestPosition!.longitude,
      };
      _addPointToPath(point, _dailyPath);
    }

    _activityCtrl?.updateTodaySteps(
      totalSteps,
      totalSteps * kmPerStep,
      totalSteps * kcalPerStep,
      path: _dailyPath,
    );
    notifyListeners();
  }

  void stop() async {
    if (!_isTracking) return;

    _stepCountSub?.cancel();
    _statusSub?.cancel();
    _positionSub?.cancel();
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);

    _stepCountSub = null;
    _statusSub = null;

    if (_runInBackground && Platform.isAndroid) {
      await FlutterForegroundTask.stopService();
    }

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
    _workoutPath = [];

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('workoutIsActive', true);
    await prefs.setString('workoutStartTime', DateTime.now().toIso8601String());

    notifyListeners();
    _updateWorkoutWidget();
    return true;
  }

  Future<void> restoreWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('workoutIsActive') == true) {
      final startTimeStr = prefs.getString('workoutStartTime');
      if (startTimeStr != null) {
        final startTime = DateTime.parse(startTimeStr);
        _workoutDurationSeconds = DateTime.now()
            .difference(startTime)
            .inSeconds;
        _workoutBaselineSteps = prefs.getInt('workoutBaselineSteps');
        _workoutSteps = 0;

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
      }
    }
  }

  Future<int> stopWorkout() async {
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

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('workoutIsActive', false);
    await prefs.remove('workoutStartTime');
    await prefs.remove('workoutBaselineSteps');

    return finalSteps;
  }

  void _onWorkoutStepCount(StepCount event) async {
    if (_workoutBaselineSteps == null) {
      _workoutBaselineSteps = event.steps;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('workoutBaselineSteps', event.steps);
    }
    _workoutSteps = event.steps - _workoutBaselineSteps!;

    if (_latestPosition != null) {
      final point = {
        'lat': _latestPosition!.latitude,
        'lng': _latestPosition!.longitude,
      };
      _addPointToPath(point, _workoutPath);
    }

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

    _checkNewDay();

    if (_latestPosition != null) {
      final point = {
        'lat': _latestPosition!.latitude,
        'lng': _latestPosition!.longitude,
      };
      _addPointToPath(point, _dailyPath);
    }

    _activityCtrl?.updateTodaySteps(
      totalSteps,
      totalSteps * kmPerStep,
      totalSteps * kcalPerStep,
      path: _dailyPath,
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
    _positionSub?.cancel();
    _workoutStepSub?.cancel();
    _workoutTimer?.cancel();
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }
}
