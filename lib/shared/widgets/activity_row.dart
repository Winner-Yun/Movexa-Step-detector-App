import 'package:flutter/material.dart';
import 'package:step_detector/core/constants/app_colors.dart';

class ActivityRow extends StatelessWidget {
  const ActivityRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.delta,
  });

  final String title;
  final String subtitle;
  final String delta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.activityCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.iconChip,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.directions_walk_rounded,
              size: 14,
              color: Color(0xFF996F1C),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF7D766B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            delta,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.positiveText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
