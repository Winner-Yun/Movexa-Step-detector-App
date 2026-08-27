import 'package:flutter/material.dart';
import 'package:step_detector/core/theme/theme_colors.dart';

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
        color: ThemeColors.getActivityCard(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: ThemeColors.getIconChip(context),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.directions_walk_rounded,
              size: 14,
              color: Color(0xFF996F1C),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: ThemeColors.getText(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 1),
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
              color: ThemeColors.getPositiveText(context),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
