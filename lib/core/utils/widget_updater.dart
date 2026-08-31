import 'package:home_widget/home_widget.dart';

class WidgetUpdater {
  static const String _androidWidgetName = 'WorkoutWidgetProvider';

  static Future<void> updateDailyStats({
    required int steps,
    required double cal,
    required double km,
  }) async {
    await HomeWidget.saveWidgetData<bool>('is_workout_mode', false);
    await HomeWidget.saveWidgetData<String>('daily_steps', steps.toString());
    await HomeWidget.saveWidgetData<String>(
      'daily_cal',
      cal.toStringAsFixed(0),
    );
    await HomeWidget.saveWidgetData<String>('daily_km', km.toStringAsFixed(2));

    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }

  static Future<void> updateWorkoutStats({
    required String time,
    required int steps,
    required double cal,
    required double km,
    required double speed,
  }) async {
    await HomeWidget.saveWidgetData<bool>('is_workout_mode', true);
    await HomeWidget.saveWidgetData<String>('workout_time', time);
    await HomeWidget.saveWidgetData<String>('workout_steps', steps.toString());
    await HomeWidget.saveWidgetData<String>(
      'workout_cal',
      cal.toStringAsFixed(0),
    );
    await HomeWidget.saveWidgetData<String>(
      'workout_km',
      km.toStringAsFixed(2),
    );
    await HomeWidget.saveWidgetData<String>(
      'workout_speed',
      speed.toStringAsFixed(1),
    );

    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }
}
