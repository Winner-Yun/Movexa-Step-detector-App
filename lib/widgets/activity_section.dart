import 'package:flutter/material.dart';

// IMPORTANT: Import your new WorkoutSession model here!

import 'package:step_detector/widgets/activity_row.dart';

class ActivitySection extends StatelessWidget {
  const ActivitySection({super.key, required this.activities});

  // Change this to expect your real Firebase model
  final List<dynamic>
  activities; // NOTE: Change `dynamic` to `WorkoutSession` once imported

  @override
  Widget build(BuildContext context) {
    // Show a clean empty state if there are no workouts yet
    if (activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'មិនទាន់មានសកម្មភាពថ្មីៗទេ (No recent activities)',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,

      // THESE TWO LINES ARE CRITICAL so it doesn't crash the dashboard scroll view
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      // Limit to showing only the 5 most recent activities on the dashboard
      itemCount: activities.length > 5 ? 5 : activities.length,

      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final session = activities[index]; // This will be a WorkoutSession

        // Format the date/time nicely for the subtitle
        final date = session.startTime;
        final hour = date.hour > 12
            ? date.hour - 12
            : (date.hour == 0 ? 12 : date.hour);
        final ampm = date.hour >= 12 ? 'PM' : 'AM';
        final min = date.minute.toString().padLeft(2, '0');
        final timeString =
            '${date.day}/${date.month}/${date.year} • $hour:$min $ampm';

        return ActivityRow(
          title: session.title,
          subtitle: timeString, // Shows the date and time
          delta: '+${session.steps}', // Shows the steps earned
        );
      },
    );
  }
}
