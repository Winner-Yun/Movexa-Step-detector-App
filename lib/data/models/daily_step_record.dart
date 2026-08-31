import 'package:step_detector/core/model/base_model.dart';
class DailyStepRecord implements BaseModel {
  final DateTime date;
  final int steps;
  final double calories;
  final double distance;

  const DailyStepRecord({
    required this.date,
    required this.steps,
    required this.calories,
    required this.distance,
  });

  bool isGoalReached(int goal) => steps >= goal;

  double getProgress(int goal) =>
      goal > 0 ? (steps / goal).clamp(0.0, 1.0) : (steps > 0 ? 1.0 : 0.0);

  @override
  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'steps': steps,
      'calories': calories,
      'distance': distance.toDouble(),
    };
  }

  factory DailyStepRecord.fromMap(Map<String, dynamic> map) {
    return DailyStepRecord(
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

