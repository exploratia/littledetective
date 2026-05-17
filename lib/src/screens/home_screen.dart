import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../features/compass/compass_view.dart';
import '../features/qr/qr_view.dart';
import 'administration_screen.dart';

enum AppTab { qr, compass, text }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppTab _selectedTab = AppTab.qr;
  String? _scannedText;

  void _selectTab(AppTab tab) {
    setState(() {
      _selectedTab = tab;
    });
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
    });
  }

  void _openAdministration() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdministrationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = switch (_selectedTab) {
      AppTab.qr => 0,
      AppTab.compass => 1,
      AppTab.text => 2,
    };

    return Scaffold(
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
              AppTab.compass => const CompassView(
                key: ValueKey('compass-view'),
              ),
              AppTab.text =>
                _scannedText == null
                    ? const _EmptyTextView(key: ValueKey('empty-text-view'))
                    : ScannedTextView(
                        key: const ValueKey('scanned-text-view'),
                        text: _scannedText!,
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
            1 => AppTab.compass,
            _ => AppTab.text,
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner, size: 30),
            selectedIcon: Icon(Icons.qr_code_2, size: 34),
            label: 'QR-Code',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined, size: 30),
            selectedIcon: Icon(Icons.explore, size: 34),
            label: 'Compass',
          ),
          NavigationDestination(
            icon: Icon(Icons.text_snippet_outlined, size: 30),
            selectedIcon: Icon(Icons.text_snippet, size: 34),
            label: 'Text',
          ),
        ],
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
