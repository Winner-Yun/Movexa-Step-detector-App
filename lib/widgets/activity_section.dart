import 'package:flutter/material.dart';
import 'package:step_detector/core/localization/app_translations.dart';
import 'package:step_detector/core/theme/theme_colors.dart';
import 'package:step_detector/data/models/daily_step_record.dart';
import 'package:step_detector/widgets/activity_row.dart';
import 'package:step_detector/widgets/stat_card.dart';

class ActivitySection extends StatelessWidget {
  const ActivitySection({super.key, required this.activities});

  final List<dynamic> activities;

  void _showDetailDialog(BuildContext context, DailyStepRecord record) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: ThemeColors.getSurface(context),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColors.getBrandAccent(
                        context,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${record.date.day}/${record.date.month}/${record.date.year}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: ThemeColors.getBrandAccent(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.directions_walk_rounded,
                        iconColor: const Color(0xFFE25B5B),
                        title: 'steps'.tr(context),
                        value: '${record.steps}',
                        unit: '',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.local_fire_department_rounded,
                        iconColor: const Color(0xFFF5A623),
                        title: 'calories'.tr(context),
                        value: record.calories.toStringAsFixed(0),
                        unit: 'KCAL',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StatCard(
                  icon: Icons.pin_drop_rounded,
                  iconColor: const Color(0xFF4A90E2),
                  title: 'distance'.tr(context),
                  value: record.distance.toStringAsFixed(2),
                  unit: 'KM',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.getBrandAccent(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'close'.tr(context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final filteredActivities = activities.where((item) {
      if (item is DailyStepRecord) {
        return item.date.year != now.year ||
            item.date.month != now.month ||
            item.date.day != now.day;
      }
      return true;
    }).toList();

    if (filteredActivities.isEmpty) {
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
      itemCount: filteredActivities.length > 5 ? 5 : filteredActivities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = filteredActivities[index];

        if (item is DailyStepRecord) {
          final date = item.date;
          final dateString = '${date.day}/${date.month}/${date.year}';

          return GestureDetector(
            onTap: () => _showDetailDialog(context, item),
            child: ActivityRow(
              title: 'dailyTrackRecord'.tr(context),
              subtitle: dateString,
              delta: '+${item.steps}',
            ),
          );
        }

        final session = item;
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
