import 'package:step_detector/core/model/base_model.dart';
class UserSettings implements BaseModel {
  final int dailyStepGoal;
  final bool runTrackingInBackground;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String language;

  const UserSettings({
    this.dailyStepGoal = 10000,
    this.runTrackingInBackground = true,
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.language = 'ខ្មែរ',
  });

  UserSettings copyWith({
    int? dailyStepGoal,
    bool? runTrackingInBackground,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? language,
  }) {
    return UserSettings(
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      runTrackingInBackground:
          runTrackingInBackground ?? this.runTrackingInBackground,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      language: language ?? this.language,
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
      language: map['language'] ?? 'ខ្មែរ',
    );
  }
}

