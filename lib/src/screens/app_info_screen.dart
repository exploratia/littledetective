import 'package:flutter/material.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to')),
      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 12,
                  children: [
                    const SizedBox(height: 24),
                    Text('Hello Detective', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 24),
                    Center(child: Image.asset('assets/app_icon.png', width: 96, height: 96, excludeFromSemantics: true)),
                    const SizedBox(height: 24),
                    _InfoLine(icon: Icons.qr_code_scanner, text: 'Scan QR-Code'),
                    _InfoLine(icon: Icons.text_snippet_outlined, text: 'Show the latest scanned content.'),
                    _InfoLine(icon: Icons.explore_outlined, text: 'Show compass for direction and geolocation.'),
                    const SizedBox(height: 24),
                    const Text('Stay curious ...'),
                    const SizedBox(height: 24),
                    Center(
                      child: IconButton.filledTonal(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close), tooltip: 'Close'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Table(
        columnWidths: const <int, TableColumnWidth>{0: FixedColumnWidth(56), 1: FlexColumnWidth()},
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              Align(alignment: Alignment.centerLeft, child: Icon(icon, size: 36)),
              Text(text, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}
