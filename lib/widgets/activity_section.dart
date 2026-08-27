import 'package:flutter/material.dart';

import 'package:step_detector/widgets/activity_row.dart';
import 'package:step_detector/core/localization/app_translations.dart';

class ActivitySection extends StatelessWidget {
  const ActivitySection({super.key, required this.activities});

  final List<dynamic>
  activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'noRecentActivities'.tr(context),
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,

      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      itemCount: activities.length > 5 ? 5 : activities.length,

      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final session = activities[index];

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
          subtitle: timeString,
          delta: '+${session.steps}',
        );
      },
    );
  }
}

