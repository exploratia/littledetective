import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class CompassView extends StatefulWidget {
  const CompassView({super.key});

  @override
  State<CompassView> createState() => _CompassViewState();
}

class _CompassViewState extends State<CompassView> with WidgetsBindingObserver {
  final Stream<Position> _positionStream = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 0),
  );

  bool _locationInitialized = false;
  bool _locationReady = false;
  String? _locationError;
  bool _settingsOpened = false;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _settingsOpened) {
      _settingsOpened = false;
      _initializeLocation();
    }
  }

  Future<void> _initializeLocation() async {
    final locationState = await _prepareLocation();
    if (!mounted) {
      return;
    }
    setState(() {
      _locationInitialized = true;
      _locationReady = locationState.errorMessage == null;
      _locationError = locationState.errorMessage;
    });

    if (locationState.showSettingsDialog) {
      await _showSettingsDialog(
        title: 'Location Permission Needed',
        message: 'Please allow location access in settings.',
      );
    }
  }

  Future<_LocationSetupResult> _prepareLocation() async {
    final isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      return const _LocationSetupResult(errorMessage: 'Location service is off.');
    }

    var permission = await Permission.locationWhenInUse.status;
    if (permission.isDenied) {
      permission = await Permission.locationWhenInUse.request();
    }

    if (permission.isGranted || permission.isLimited) {
      return const _LocationSetupResult();
    }

    if (permission.isPermanentlyDenied) {
      return const _LocationSetupResult(errorMessage: 'Location access is blocked.', showSettingsDialog: true);
    }

    return const _LocationSetupResult(errorMessage: 'Location permission denied.');
  }

  Future<void> _showSettingsDialog({
    required String title,
    required String message,
  }) async {
    if (!mounted || _dialogOpen) {
      return;
    }

    _dialogOpen = true;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _settingsOpened = true;
                openAppSettings();
                Navigator.of(context).pop();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
    _dialogOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        final heading = snapshot.data?.heading;

        if (heading == null) {
          return const Center(child: Text('No compass sensor found.', textAlign: TextAlign.center));
        }

        if (!_locationInitialized) {
          return Center(
            child: CompassRose(heading: heading, locationStatus: 'Detecting location...'),
          );
        }

        if (!_locationReady) {
          return Center(
            child: CompassRose(heading: heading, locationStatus: _locationError),
          );
        }

        return StreamBuilder<Position>(
          stream: _positionStream,
          builder: (context, positionSnapshot) {
            final locationStatus = positionSnapshot.hasError ? 'Unable to read location.' : null;
            return Center(
              child: CompassRose(heading: heading, position: positionSnapshot.data, locationStatus: locationStatus),
            );
          },
        );
      },
    );
  }
}

class _LocationSetupResult {
  const _LocationSetupResult({this.errorMessage, this.showSettingsDialog = false});

  final String? errorMessage;
  final bool showSettingsDialog;
}

class CompassRose extends StatelessWidget {
  const CompassRose({required this.heading, this.position, this.locationStatus, super.key});

  final double heading;
  final Position? position;
  final String? locationStatus;

  @override
  Widget build(BuildContext context) {
    final rotation = heading * (math.pi / 180) * -1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Transform.rotate(
              angle: rotation,
              child: CustomPaint(
                size: const Size.square(320),
                painter: _CompassRosePainter(colorScheme: Theme.of(context).colorScheme),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('${heading.round()}\u00B0', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (locationStatus != null)
          Text(
            locationStatus!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
          )
        else if (position == null)
          Text('Locating...', style: Theme.of(context).textTheme.bodyMedium)
        else
          Column(
            children: [
              Text(
                'Lat ${position!.latitude.toStringAsFixed(5)}\u00B0, Lon ${position!.longitude.toStringAsFixed(5)}\u00B0',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 2),
              Text('Alt ${position!.altitude.toStringAsFixed(1)} m', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
      ],
    );
  }
}

class _CompassRosePainter extends CustomPainter {
  const _CompassRosePainter({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final ringPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final tickPaint = Paint()
      ..color = colorScheme.onSurface
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    final northPaint = Paint()..color = const Color(0xFFE53935);
    final southPaint = Paint()..color = colorScheme.primary;

    canvas.drawCircle(center, radius - 8, ringPaint);

    for (var i = 0; i < 360; i += 15) {
      final isCardinal = i % 90 == 0;
      final angle = (i - 90) * math.pi / 180;
      final startRadius = radius - (isCardinal ? 34 : 22);
      final endRadius = radius - 10;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * startRadius,
        center + Offset(math.cos(angle), math.sin(angle)) * endRadius,
        tickPaint..strokeWidth = isCardinal ? 5 : 2,
      );
    }

    _drawNeedle(canvas, center, radius, northPaint, southPaint);
    _drawLabels(canvas, center, radius);
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius, Paint northPaint, Paint southPaint) {
    final northPath = Path()
      ..moveTo(center.dx, center.dy - radius + 78)
      ..lineTo(center.dx - 18, center.dy)
      ..lineTo(center.dx + 18, center.dy)
      ..close();
    final southPath = Path()
      ..moveTo(center.dx, center.dy + radius - 78)
      ..lineTo(center.dx - 18, center.dy)
      ..lineTo(center.dx + 18, center.dy)
      ..close();

    canvas
      ..drawPath(northPath, northPaint)
      ..drawPath(southPath, southPaint)
      ..drawCircle(center, 10, Paint()..color = colorScheme.onSurface);
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    const labels = {'N': -90.0, 'E': 0.0, 'S': 90.0, 'W': 180.0};

    for (final entry in labels.entries) {
      final angle = entry.value * math.pi / 180;
      final position = center + Offset(math.cos(angle), math.sin(angle)) * (radius - 50);
      final style = TextStyle(color: entry.key == 'N' ? const Color(0xFFE53935) : colorScheme.onSurface, fontSize: 34, fontWeight: FontWeight.w800);
      final painter = TextPainter(
        text: TextSpan(text: entry.key, style: style),
        textDirection: TextDirection.ltr,
      )..layout();

      painter.paint(canvas, position - Offset(painter.width / 2, painter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _CompassRosePainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme;
  }
}
