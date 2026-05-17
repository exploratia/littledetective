import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrView extends StatelessWidget {
  const QrView({required this.scannedText, required this.onDetect, super.key});

  final String? scannedText;
  final void Function(BarcodeCapture capture) onDetect;

  @override
  Widget build(BuildContext context) {
    if (scannedText != null) {
      return ScannedTextView(text: scannedText!);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(onDetect: onDetect),
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
