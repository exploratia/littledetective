import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QrView extends StatefulWidget {
  const QrView({required this.onDetect, super.key});

  final void Function(BarcodeCapture capture) onDetect;

  @override
  State<QrView> createState() => _QrViewState();
}

class _QrViewState extends State<QrView> with WidgetsBindingObserver {
  final MobileScannerController _scannerController = MobileScannerController();

  bool? _cameraReady;
  String? _cameraMessage;
  bool _settingsOpened = false;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _settingsOpened) {
      _settingsOpened = false;
      _checkCameraPermission();
    }
  }

  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (!mounted) {
      return;
    }

    if (status.isGranted || status.isLimited) {
      setState(() {
        _cameraReady = true;
        _cameraMessage = null;
      });
      return;
    }

    if (status.isPermanentlyDenied) {
      setState(() {
        _cameraReady = false;
        _cameraMessage = 'Camera access is blocked.';
      });
      _showSettingsDialog(
        title: 'Camera Permission Needed',
        message: 'Please allow camera access in settings.',
      );
      return;
    }

    setState(() {
      _cameraReady = false;
      _cameraMessage = 'Camera permission denied.';
    });
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
    if (_cameraReady == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cameraReady == false) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 42),
            const SizedBox(height: 12),
            Text(
              _cameraMessage ?? 'Camera permission required.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _checkCameraPermission,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _scannerController, onDetect: widget.onDetect),
          const _ScannerFrame(),
        ],
      ),
    );
  }
}

class ScannedTextView extends StatelessWidget {
  const ScannedTextView({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Text',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(right: 12),
                child: SelectableText(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(height: 1.45),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
