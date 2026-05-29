import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/compass/compass_view.dart';
import '../features/qr/qr_view.dart';
import 'administration_screen.dart';
import 'app_info_screen.dart';

enum AppTab { qr, compass, text }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _storedQrTextKey = 'stored_qr_text';
  static const _storedVersionKey = 'stored_app_version';
  static const _exitHintDuration = Duration(seconds: 2);

  AppTab _selectedTab = AppTab.qr;
  String? _scannedText;
  SharedPreferences? _preferences;
  bool _isExitArmed = false;
  Timer? _exitArmResetTimer;

  @override
  void initState() {
    super.initState();
    _loadPersistedState();
  }

  @override
  void dispose() {
    _exitArmResetTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPersistedState() async {
    final preferences = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.buildNumber.trim().isEmpty
        ? packageInfo.version
        : '${packageInfo.version}+${packageInfo.buildNumber}';
    final storedVersion = preferences.getString(_storedVersionKey);
    final shouldShowInfoView = storedVersion == null;

    if (storedVersion != currentVersion) {
      await preferences.setString(_storedVersionKey, currentVersion);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _preferences = preferences;
      _scannedText = preferences.getString(_storedQrTextKey);
    });

    if (shouldShowInfoView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _openInfoView();
        }
      });
    }
  }

  Future<void> _storeScannedText(String value) async {
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    _preferences = preferences;
    await preferences.setString(_storedQrTextKey, value);
  }

  void _selectTab(AppTab tab) {
    setState(() {
      _selectedTab = tab;
      _isExitArmed = false;
    });
    _exitArmResetTimer?.cancel();
  }

  void _handleBarcode(BarcodeCapture capture) {
    final value = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .where((text) => text.trim().isNotEmpty)
        .firstOrNull;

    if (value == null) {
      return;
    }

    setState(() {
      _scannedText = value;
      _selectedTab = AppTab.text;
      _isExitArmed = false;
    });
    _exitArmResetTimer?.cancel();
    unawaited(_storeScannedText(value));
  }

  void _openAdministration() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdministrationScreen()),
    );
  }

  void _openInfoView() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AppInfoScreen()),
    );
  }

  void _handleBackNavigation() {
    if (_selectedTab != AppTab.qr) {
      _selectTab(AppTab.qr);
      return;
    }

    if (_isExitArmed) {
      return;
    }

    setState(() {
      _isExitArmed = true;
    });

    _exitArmResetTimer?.cancel();
    _exitArmResetTimer = Timer(_exitHintDuration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isExitArmed = false;
      });
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Press again to exit'),
          duration: _exitHintDuration,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = switch (_selectedTab) {
      AppTab.qr => 0,
      AppTab.text => 1,
      AppTab.compass => 2,
    };

    return PopScope(
      canPop: _selectedTab == AppTab.qr && _isExitArmed,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackNavigation();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Image.asset(
            'assets/app_icon.png',
            width: 48,
            height: 48,
            excludeFromSemantics: true,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: _openInfoView,
                icon: const Icon(Icons.help_outline),
                tooltip: 'Info',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: _openAdministration,
                icon: const Icon(Icons.info_outline),
                tooltip: 'Administration',
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: switch (_selectedTab) {
                AppTab.qr => QrView(
                  key: const ValueKey('qr-view'),
                  onDetect: _handleBarcode,
                ),
                AppTab.text =>
                  _scannedText == null
                      ? const _EmptyTextView(key: ValueKey('empty-text-view'))
                      : ScannedTextView(
                          key: const ValueKey('scanned-text-view'),
                          text: _scannedText!,
                        ),
                AppTab.compass => const CompassView(
                  key: ValueKey('compass-view'),
                ),
              },
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          onDestinationSelected: (index) {
            _selectTab(switch (index) {
              0 => AppTab.qr,
              1 => AppTab.text,
              _ => AppTab.compass,
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.qr_code_scanner, size: 30),
              selectedIcon: Icon(Icons.qr_code_2, size: 34),
              label: 'QR-Code',
            ),
            NavigationDestination(
              icon: Icon(Icons.text_snippet_outlined, size: 30),
              selectedIcon: Icon(Icons.text_snippet, size: 34),
              label: 'Text',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined, size: 30),
              selectedIcon: Icon(Icons.explore, size: 34),
              label: 'Compass',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTextView extends StatelessWidget {
  const _EmptyTextView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Text(
        '🫣',
        textAlign: TextAlign.center,
        style: textTheme.titleLarge,
      ),
    );
  }
}
