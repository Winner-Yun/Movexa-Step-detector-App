import 'package:step_detector/core/model/base_model.dart';
class WorkoutSession implements BaseModel {
  final String id;
  final String title;
  final DateTime startTime;
  final Duration duration;
  final int steps;
  final double calories;
  final double distance;
  final String averagePace;
  final double speedKmh;
  final List<double>? paceChartData;

  const WorkoutSession({
    required this.id,
    required this.title,
    required this.startTime,
    required this.duration,
    required this.steps,
    required this.calories,
    required this.distance,
    required this.averagePace,
    required this.speedKmh,
    this.paceChartData,
  });

  String get formattedDuration {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.millisecondsSinceEpoch,
      'durationSeconds': duration.inSeconds.toDouble(),
      'steps': steps,
      'calories': calories,
      'distance': distance.toDouble(),
      'averagePace': averagePace,
      'speedKmh': speedKmh,
      'paceChartData': paceChartData,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Workout',
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      duration: Duration(seconds: (map['durationSeconds'] as num?)?.toInt() ?? 0),
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
      averagePace: map['averagePace'] ?? '0:00',
      speedKmh: (map['speedKmh'] as num?)?.toDouble() ?? 0.0,
      paceChartData: (map['paceChartData'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }
}

