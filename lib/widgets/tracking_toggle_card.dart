import 'package:flutter/material.dart';

import 'package:step_detector/core/constants/app_colors.dart';
import 'package:step_detector/data/controller/motion_controller.dart';

class TrackingToggleCard extends StatelessWidget {
  const TrackingToggleCard({
    super.key,
    required this.enabled,
    required this.motionStatus,
    required this.isTracking,
    required this.permissionDenied,
    required this.onChanged,
  });

  final bool enabled;
  final MotionStatus motionStatus;
  final bool isTracking;
  final bool permissionDenied;
  final ValueChanged<bool> onChanged;

  String get _subtitle {
    if (permissionDenied) return 'Motion permission denied';
    if (!isTracking) return 'Run on background app';
    return switch (motionStatus) {
      MotionStatus.walking => 'Walking now',
      MotionStatus.stopped => 'Tracking • stopped',
      _ => 'Tracking active',
    };
  }

  Color get _subtitleColor {
    if (permissionDenied) return Colors.redAccent;
    if (isTracking && motionStatus == MotionStatus.walking) {
      return AppColors.positiveText;
    }
    return AppColors.mutedText;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardNeutral,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            isTracking && motionStatus == MotionStatus.walking
                ? Icons.directions_walk_rounded
                : Icons.track_changes_rounded,
            color: AppColors.brandAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Track Record',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: _subtitleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeThumbColor: AppColors.brandAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
