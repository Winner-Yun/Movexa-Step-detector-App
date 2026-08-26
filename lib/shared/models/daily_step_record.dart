class DailyStepRecord {
  final DateTime date;
  final int steps;
  final int target;
  final double calories;
  final double distance;

  const DailyStepRecord({
    required this.date,
    required this.steps,
    required this.target,
    required this.calories,
    required this.distance,
  });

  // UI Helper: Check if goal is reached
  bool get isGoalReached => steps >= target;

  // UI Helper: Get progress percentage (0.0 to 1.0)
  double get progress => (steps / target).clamp(0.0, 1.0);

  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'steps': steps,
      'target': target,
      'calories': calories,
      'distance': distance,
    };
  }

  factory DailyStepRecord.fromMap(Map<String, dynamic> map) {
    return DailyStepRecord(
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      steps: map['steps']?.toInt() ?? 0,
      target: map['target']?.toInt() ?? 10000,
      calories: map['calories']?.toDouble() ?? 0.0,
      distance: map['distance']?.toDouble() ?? 0.0,
    );
  }
}
