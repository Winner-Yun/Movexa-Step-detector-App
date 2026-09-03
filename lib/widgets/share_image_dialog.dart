import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_detector/core/localization/app_translations.dart';
import 'package:step_detector/core/theme/theme_colors.dart';
import 'package:step_detector/data/controller/settings_controller.dart';
import 'package:step_detector/data/models/daily_step_record.dart';
import 'package:step_detector/data/models/workout_session.dart';
import 'package:step_detector/widgets/map_path_viewer.dart';

Widget _buildImageStatItem(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    ],
  );
}

class BaseShareImageDialog extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    bool mapIsDark,
    double lineSize,
    void Function(GoogleMapController) onMapCreated,
  )
  contentBuilder;
  final List<Map<String, dynamic>>? path;
  final String fileNamePrefix;

  const BaseShareImageDialog({
    super.key,
    required this.contentBuilder,
    required this.path,
    required this.fileNamePrefix,
  });

  @override
  State<BaseShareImageDialog> createState() => _BaseShareImageDialogState();
}

class _BaseShareImageDialogState extends State<BaseShareImageDialog> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSaving = false;
  bool _mapIsDark = true;
  double _lineSize = 5.0;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadMapPreference();
  }

  Future<void> _loadMapPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _mapIsDark = prefs.getBool('map_is_dark_export') ?? true;
        _lineSize = context.read<SettingsController>().settings.mapLineSize;
      });
    }
  }

  void _saveLineSizeToSettings() {
    final settingsCtrl = context.read<SettingsController>();
    settingsCtrl.updateSettings(
      settingsCtrl.settings.copyWith(mapLineSize: _lineSize),
    );
  }

  Future<void> _setMapPreference(bool value) async {
    setState(() => _mapIsDark = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('map_is_dark_export', value);
  }

  Future<void> _captureAndSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final request = await Gal.requestAccess();
        if (!request) {
          setState(() => _isSaving = false);
          return;
        }
      }

      await Future.delayed(const Duration(milliseconds: 100));

      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _isSaving = false);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes != null) {
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/${widget.fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(path);
        await file.writeAsBytes(pngBytes);
        await Gal.putImage(path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('imageSaved'.tr(context, listen: false)),
              backgroundColor: ThemeColors.getBrandAccent(context),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('Error saving image: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              key: _repaintKey,
              child: widget.contentBuilder(
                context,
                _mapIsDark,
                _lineSize,
                (c) => _mapController = c,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ThemeColors.getSurface(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'editMap'.tr(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          if (widget.path != null && widget.path!.isNotEmpty) {
                            final validPoints = widget.path!
                                .where((p) => p['gap'] != true)
                                .map((e) => LatLng(e['lat'], e['lng']))
                                .toList();
                            if (validPoints.isNotEmpty) {
                              _mapController?.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  validPoints.last,
                                  17,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.my_location_rounded, size: 16),
                        label: Text('center'.tr(context)),
                        style: TextButton.styleFrom(
                          foregroundColor: ThemeColors.getBrandAccent(context),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    title: Text(
                      'darkMapStyle'.tr(context),
                      style: TextStyle(
                        color: ThemeColors.getText(context),
                        fontSize: 14,
                      ),
                    ),
                    value: _mapIsDark,
                    onChanged: _setMapPreference,
                    activeColor: ThemeColors.getBrandAccent(context),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'zoomLevel'.tr(context),
                        style: TextStyle(
                          color: ThemeColors.getText(context),
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: ThemeColors.getText(context),
                            ),
                            onPressed: () => _mapController?.animateCamera(
                              CameraUpdate.zoomOut(),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: ThemeColors.getText(context),
                            ),
                            onPressed: () => _mapController?.animateCamera(
                              CameraUpdate.zoomIn(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'lineSize'.tr(context),
                        style: TextStyle(
                          color: ThemeColors.getText(context),
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: ThemeColors.getText(context),
                            ),
                            onPressed: () {
                              if (_lineSize > 1) {
                                setState(() => _lineSize -= 1);
                                _saveLineSizeToSettings();
                              }
                            },
                          ),
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${_lineSize.toInt()}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ThemeColors.getText(context),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: ThemeColors.getText(context),
                            ),
                            onPressed: () {
                              if (_lineSize < 20) {
                                setState(() => _lineSize += 1);
                                _saveLineSizeToSettings();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _captureAndSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.download_rounded, color: Colors.white),
              label: Text(
                _isSaving ? '...' : 'download'.tr(context),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.getBrandAccent(context),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'cancel'.tr(context),
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShareDailySummaryDialog extends StatelessWidget {
  final DailyStepRecord record;
  final int stepGoal;

  const ShareDailySummaryDialog({
    super.key,
    required this.record,
    required this.stepGoal,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BaseShareImageDialog(
      path: record.path,
      fileNamePrefix: 'movexa_daily',
      contentBuilder: (context, mapIsDark, lineSize, onMapCreated) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A2D34), Color(0xFF13151A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'movexaDailySummary'.tr(context),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  Image.asset(
                    'assets/Movexa.png',
                    width: 24,
                    height: 24,
                    color: Colors.white70,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${record.steps} ${'steps'.tr(context)}',
                style: textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${record.date.day.toString().padLeft(2, '0')}/${record.date.month.toString().padLeft(2, '0')}/${record.date.year}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              MapPathViewer(
                path: record.path,
                height: 140,
                interactive: true,
                isDarkStyle: mapIsDark,
                hideMapControls: true,
                showMarker: false,
                showResetButton: false,
                lineSize: lineSize,
                onMapCreated: onMapCreated,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildImageStatItem(
                      'distance'.tr(context),
                      '${record.distance.toStringAsFixed(2)}km',
                    ),
                  ),
                  Expanded(
                    child: _buildImageStatItem(
                      'calories'.tr(context),
                      '${record.calories.toStringAsFixed(0)}kcal',
                    ),
                  ),
                  Expanded(
                    child: _buildImageStatItem(
                      'stepGoal'.tr(context),
                      '$stepGoal',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ShareWorkoutSessionDialog extends StatelessWidget {
  final WorkoutSession session;

  const ShareWorkoutSessionDialog({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BaseShareImageDialog(
      path: session.path,
      fileNamePrefix: 'movexa_workout',
      contentBuilder: (context, mapIsDark, lineSize, onMapCreated) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A2D34), Color(0xFF13151A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'movexaWorkout'.tr(context),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  Image.asset(
                    'assets/Movexa.png',
                    width: 24,
                    height: 24,
                    color: Colors.white70,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${session.distance.toStringAsFixed(2)} KM',
                style: textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${session.startTime.day.toString().padLeft(2, '0')}/${session.startTime.month.toString().padLeft(2, '0')}/${session.startTime.year}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              MapPathViewer(
                path: session.path,
                height: 140,
                interactive: true,
                isDarkStyle: mapIsDark,
                hideMapControls: true,
                showMarker: false,
                showResetButton: false,
                lineSize: lineSize,
                onMapCreated: onMapCreated,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildImageStatItem(
                      'distance'.tr(context),
                      '${session.distance.toStringAsFixed(2)}km',
                    ),
                  ),
                  Expanded(
                    child: _buildImageStatItem(
                      'duration'.tr(context),
                      session.formattedDuration,
                    ),
                  ),
                  Expanded(
                    child: _buildImageStatItem(
                      'calories'.tr(context),
                      '${session.calories.toStringAsFixed(0)}kcal',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildImageStatItem(
                      'speed'.tr(context),
                      '${session.speedKmh.toStringAsFixed(1)}km/h',
                    ),
                  ),
                  Expanded(
                    child: _buildImageStatItem(
                      'pace'.tr(context),
                      session.averagePace,
                    ),
                  ),
                  Expanded(
                    child: _buildImageStatItem(
                      'steps'.tr(context),
                      '${session.steps}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
