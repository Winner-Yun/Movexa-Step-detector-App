import 'package:flutter/material.dart';
import 'package:step_detector/core/localization/app_translations.dart';
import 'package:step_detector/core/theme/theme_colors.dart';
import 'package:step_detector/data/controller/motion_controller.dart';

class TrackingToggleCard extends StatefulWidget {
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

  @override
  State<TrackingToggleCard> createState() => _TrackingToggleCardState();
}

class _TrackingToggleCardState extends State<TrackingToggleCard> {
  late bool _localEnabled;

  @override
  void initState() {
    super.initState();
    _localEnabled = widget.enabled;
  }

  @override
  void didUpdateWidget(TrackingToggleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _localEnabled = widget.enabled;
    }
  }

  void _handleTap() {
    setState(() {
      _localEnabled = !_localEnabled;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        widget.onChanged(_localEnabled);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeColors.getCardNeutral(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            widget.isTracking && widget.motionStatus == MotionStatus.walking
                ? Icons.directions_walk_rounded
                : Icons.track_changes_rounded,
            color: ThemeColors.getBrandAccent(context),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'dailyTrackRecord'.tr(context),
                  style: textTheme.titleSmall?.copyWith(
                    color: ThemeColors.getText(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _handleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutBack,
              width: 52,
              height: 30,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: _localEnabled
                    ? ThemeColors.getBrandAccent(context)
                    : ThemeColors.getMutedText(context).withValues(alpha: 0.2),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutBack,
                alignment: _localEnabled
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
