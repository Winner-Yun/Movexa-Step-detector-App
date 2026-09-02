import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:step_detector/core/theme/map_styles.dart';
import 'package:step_detector/core/theme/theme_colors.dart';

class MapPathViewer extends StatefulWidget {
  final List<Map<String, dynamic>>? path;
  final double height;
  final bool interactive;
  final bool? isDarkStyle;
  final bool hideMapControls;
  final double markerSize;
  final void Function(GoogleMapController)? onMapCreated;

  const MapPathViewer({
    super.key,
    required this.path,
    this.height = 200,
    this.interactive = true,
    this.isDarkStyle,
    this.hideMapControls = false,
    this.markerSize = 20.0,
    this.onMapCreated,
  });

  @override
  State<MapPathViewer> createState() => _MapPathViewerState();
}

class _MapPathViewerState extends State<MapPathViewer> {
  BitmapDescriptor? _customIcon;
  GoogleMapController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCustomMarker();
    _updateMapStyle();
  }

  @override
  void didUpdateWidget(MapPathViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.markerSize != widget.markerSize) {
      _loadCustomMarker();
    }
    if (oldWidget.isDarkStyle != widget.isDarkStyle) {
      _updateMapStyle();
    }
  }

  void _updateMapStyle() {
    if (_controller == null) return;
    final useDark = widget.isDarkStyle ?? Theme.of(context).brightness == Brightness.dark;
    _controller!.setMapStyle(useDark ? MapStyles.dark : null);
  }

  Future<void> _loadCustomMarker() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double size = widget.markerSize;

    final Paint paint = Paint()..color = Colors.lightBlue;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData != null && mounted) {
      setState(() {
        _customIcon = BitmapDescriptor.bytes(byteData.buffer.asUint8List());
      });
    }
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

    final points = widget.path!.map((e) => LatLng(e['lat'], e['lng'])).toList();

    // Calculate bounds to fit the path
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    return Container(
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
          initialCameraPosition: CameraPosition(target: points.last, zoom: 15),
          minMaxZoomPreference: const MinMaxZoomPreference(null, 17),
          polylines: {
            Polyline(
              polylineId: const PolylineId('path'),
              points: points,
              color: ThemeColors.getBrandAccent(context),
              width: 5,
              jointType: JointType.round,
            ),
          },
          markers: {
            Marker(
              markerId: const MarkerId('current'),
              position: points.last,
              icon: _customIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ),
          },
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

            if (points.length > 1) {
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
    );
  }
}
