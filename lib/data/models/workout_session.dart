class WorkoutSession {
  final String id;
  final String title;
  final DateTime startTime;
  final Duration duration;
  final int steps;
  final double calories;
  final double distance; // in km
  final String averagePace; // e.g., "6:35"
  final List<double>? paceChartData; // For the bar chart on the detail page

  const WorkoutSession({
    required this.id,
    required this.title,
    required this.startTime,
    required this.duration,
    required this.steps,
    required this.calories,
    required this.distance,
    required this.averagePace,
    this.paceChartData,
  });

  // Helper method to format duration to "MM:SS" for UI
  String get formattedDuration {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.millisecondsSinceEpoch,
      'durationSeconds': duration.inSeconds,
      'steps': steps,
      'calories': calories,
      'distance': distance,
      'averagePace': averagePace,
      'paceChartData': paceChartData,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Workout',
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      duration: Duration(seconds: map['durationSeconds'] ?? 0),
      steps: map['steps']?.toInt() ?? 0,
      calories: map['calories']?.toDouble() ?? 0.0,
      distance: map['distance']?.toDouble() ?? 0.0,
      averagePace: map['averagePace'] ?? '0:00',
      paceChartData: List<double>.from(map['paceChartData'] ?? []),
    );
  }
}
