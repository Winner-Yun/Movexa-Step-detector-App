import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:step_detector/core/theme/map_styles.dart';
import 'package:step_detector/core/theme/theme_colors.dart';
import 'package:step_detector/data/controller/settings_controller.dart';

class MapPathViewer extends StatefulWidget {
  final List<Map<String, dynamic>>? path;
  final double height;
  final bool interactive;
  final bool? isDarkStyle;
  final bool hideMapControls;
  final double? markerSize;
  final double? lineSize;
  final bool showMarker;
  final bool showResetButton;
  final void Function(GoogleMapController)? onMapCreated;

  const MapPathViewer({
    super.key,
    required this.path,
    this.height = 200,
    this.interactive = true,
    this.isDarkStyle,
    this.hideMapControls = false,
    this.markerSize,
    this.lineSize,
    this.showMarker = true,
    this.showResetButton = true,
    this.onMapCreated,
  });

  @override
  State<MapPathViewer> createState() => _MapPathViewerState();
}

class _MapPathViewerState extends State<MapPathViewer> {
  GoogleMapController? _controller;
  BitmapDescriptor? _circleIcon;
  double _lastBuiltMarkerSize = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMapStyle();
  }

  @override
  void didUpdateWidget(MapPathViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkStyle != widget.isDarkStyle) {
      _updateMapStyle();
    }
  }

  Future<void> _buildCircleIcon(double size) async {
    if (_lastBuiltMarkerSize == size && _circleIcon != null) return;
    _lastBuiltMarkerSize = size;
    
    final int physicalSize = (size * MediaQuery.of(context).devicePixelRatio).toInt();
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.lightBlueAccent;
    canvas.drawCircle(Offset(physicalSize / 2, physicalSize / 2), physicalSize / 2, paint);
    
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = physicalSize * 0.15;
    canvas.drawCircle(Offset(physicalSize / 2, physicalSize / 2), (physicalSize / 2) - borderPaint.strokeWidth / 2, borderPaint);

    final ui.Image image = await pictureRecorder.endRecording().toImage(physicalSize, physicalSize);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      if (mounted) {
        setState(() {
          _circleIcon = BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
        });
      }
    }
  }

  void _updateMapStyle() {
    if (_controller == null) return;
    final useDark =
        widget.isDarkStyle ?? Theme.of(context).brightness == Brightness.dark;
    _controller!.setMapStyle(useDark ? MapStyles.dark : null);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.path == null || widget.path!.isEmpty) {
      return Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: ThemeColors.getSurface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ThemeColors.getMutedText(context).withValues(alpha: 0.1),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_rounded,
                color: ThemeColors.getMutedText(context).withValues(alpha: 0.5),
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'No path data available',
                style: TextStyle(
                  color: ThemeColors.getMutedText(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final validPoints = widget.path!
        .where((p) => p['gap'] != true)
        .map((e) => LatLng(e['lat'], e['lng']))
        .toList();

    if (validPoints.isEmpty) {
      return Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: ThemeColors.getSurface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ThemeColors.getMutedText(context).withValues(alpha: 0.1),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_rounded,
                color: ThemeColors.getMutedText(context).withValues(alpha: 0.5),
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'No path data available',
                style: TextStyle(
                  color: ThemeColors.getMutedText(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    double minLat = validPoints.first.latitude;
    double maxLat = validPoints.first.latitude;
    double minLng = validPoints.first.longitude;
    double maxLng = validPoints.first.longitude;

    for (final p in validPoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    final settingsCtrl = context.watch<SettingsController>();
    final double currentLineSize = widget.lineSize ?? settingsCtrl.settings.mapLineSize;
    final double currentMarkerSize = widget.markerSize ?? settingsCtrl.settings.mapMarkerSize;

    if (widget.showMarker) {
      _buildCircleIcon(currentMarkerSize);
    }

    final polylines = <Polyline>{};
    List<LatLng> currentSegment = [];
    int segmentIndex = 0;

    for (final p in widget.path!) {
      if (p['gap'] == true) {
        if (currentSegment.isNotEmpty) {
          polylines.add(
            Polyline(
              polylineId: PolylineId('path_$segmentIndex'),
              points: List.from(currentSegment),
              color: ThemeColors.getBrandAccent(context),
              width: currentLineSize.toInt(),
              jointType: JointType.round,
            ),
          );
          segmentIndex++;
          currentSegment.clear();
        }
      } else {
        currentSegment.add(LatLng(p['lat'], p['lng']));
      }
    }

    if (currentSegment.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: PolylineId('path_$segmentIndex'),
          points: currentSegment,
          color: ThemeColors.getBrandAccent(context),
          width: currentLineSize.toInt(),
          jointType: JointType.round,
        ),
      );
    }

    final markers = <Marker>{};
    if (widget.showMarker && _circleIcon != null && validPoints.isNotEmpty) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_pos'),
          position: validPoints.last,
          icon: _circleIcon!,
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ThemeColors.getText(context).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: validPoints.last,
                zoom: 15,
              ),
          minMaxZoomPreference: const MinMaxZoomPreference(null, 17),
          polylines: polylines,
          markers: markers,
          zoomControlsEnabled: widget.interactive && !widget.hideMapControls,
          zoomGesturesEnabled: widget.interactive,
          scrollGesturesEnabled: widget.interactive,
          gestureRecognizers: widget.interactive
              ? <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                }
              : const <Factory<OneSequenceGestureRecognizer>>{},
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (controller) {
            _controller = controller;
            _updateMapStyle();

            if (validPoints.length > 1) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  _controller?.animateCamera(
                    CameraUpdate.newLatLngBounds(bounds, 80),
                  );
                }
              });
            }
            widget.onMapCreated?.call(controller);
          },
        ),
      ),
    ),
      if (widget.showResetButton && validPoints.isNotEmpty)
        Positioned(
          top: 12,
          left: 12,
          child: GestureDetector(
            onTap: () {
              _controller?.animateCamera(
                CameraUpdate.newLatLngZoom(validPoints.last, 17),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ThemeColors.getBrandAccent(context),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
