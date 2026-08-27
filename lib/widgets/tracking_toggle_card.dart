import 'package:flutter/material.dart';
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

  String _getSubtitle() {
    if (widget.permissionDenied) return 'Motion permission denied';
    if (!widget.isTracking) return 'Run on background app';
    return switch (widget.motionStatus) {
      MotionStatus.walking => 'Walking now',
      MotionStatus.stopped => 'Tracking • stopped',
      _ => 'Tracking active',
    };
  }

  Color _getSubtitleColor(BuildContext context) {
    if (widget.permissionDenied) return Colors.redAccent;
    if (widget.isTracking && widget.motionStatus == MotionStatus.walking) {
      return ThemeColors.getPositiveText(context);
    }
    return ThemeColors.getMutedText(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitle = _getSubtitle();
    final subtitleColor = _getSubtitleColor(context);

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
                  'Daily Track Record',
                  style: textTheme.titleSmall?.copyWith(
                    color: ThemeColors.getText(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: subtitleColor,
                    fontWeight: FontWeight.w600,
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
                alignment: _localEnabled ? Alignment.centerRight : Alignment.centerLeft,
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
