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

  double getProgress(int goal) => (steps / goal).clamp(0.0, 1.0);

  @override
  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'steps': steps,
      'calories': calories,
      'distance': distance,
    };
  }

  factory DailyStepRecord.fromMap(Map<String, dynamic> map) {
    return DailyStepRecord(
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      steps: map['steps']?.toInt() ?? 0,
      calories: map['calories']?.toDouble() ?? 0.0,
      distance: map['distance']?.toDouble() ?? 0.0,
    );
  }
}

