import 'package:step_detector/core/model/base_model.dart';

class UserSettings implements BaseModel {
  final int dailyStepGoal;
  final bool runTrackingInBackground;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String language;
  final double mapLineSize;
  final double mapMarkerSize;
  final int defaultTabMode;

  const UserSettings({
    this.dailyStepGoal = 10000,
    this.runTrackingInBackground = true,
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.language = 'km',
    this.mapLineSize = 5.0,
    this.mapMarkerSize = 20.0,
    this.defaultTabMode = 0,
  });

  UserSettings copyWith({
    int? dailyStepGoal,
    bool? runTrackingInBackground,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? language,
    double? mapLineSize,
    double? mapMarkerSize,
    int? defaultTabMode,
  }) {
    return UserSettings(
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      runTrackingInBackground:
          runTrackingInBackground ?? this.runTrackingInBackground,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      language: language ?? this.language,
      mapLineSize: mapLineSize ?? this.mapLineSize,
      mapMarkerSize: mapMarkerSize ?? this.mapMarkerSize,
      defaultTabMode: defaultTabMode ?? this.defaultTabMode,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'dailyStepGoal': dailyStepGoal,
      'runTrackingInBackground': runTrackingInBackground,
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'language': language,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      dailyStepGoal: map['dailyStepGoal']?.toInt() ?? 10000,
      runTrackingInBackground: map['runTrackingInBackground'] ?? true,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      darkModeEnabled: map['darkModeEnabled'] ?? false,
      language: map['language'] ?? 'km',
      mapLineSize: map['mapLineSize']?.toDouble() ?? 5.0,
      mapMarkerSize: map['mapMarkerSize']?.toDouble() ?? 20.0,
      defaultTabMode: map['defaultTabMode']?.toInt() ?? 0,
    );
  }
}
