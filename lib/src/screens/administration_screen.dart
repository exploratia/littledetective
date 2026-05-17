import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdministrationScreen extends StatelessWidget {
  const AdministrationScreen({super.key});

  static final Uri _buyMeACoffeeUri = Uri.parse('https://coff.ee/exploratia');
  static final Uri _littleDetectiveUri = Uri.parse(
    'https://github.com/exploratia/littledetective',
  );
  static final Uri _exploratiaUri = Uri.parse('https://www.exploratia.de');
  static final Uri _issueUri = Uri.parse(
    'https://github.com/exploratia/littledetective/issues',
  );

  Future<void> _openLink(BuildContext context, Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $uri')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Info')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AdministrationCard(
              title: 'Support the App',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Maintaining and improving this app takes a lot of free time. Any support is appreciated.',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _openLink(context, _buyMeACoffeeUri),
                    icon: const Icon(Icons.local_cafe_outlined),
                    label: const Text('Buy me a coffee'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _openLink(context, _issueUri),
                    icon: const Icon(Icons.bug_report_outlined),
                    label: const Text('Report a bug on GitHub'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _AdministrationCard(
              title: 'Little Detective',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Little Detective is a simple app with QR scanner and compass for kids.',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _openLink(context, _littleDetectiveUri),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Little Detective on GitHub'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _openLink(context, _exploratiaUri),
                        icon: const Icon(Icons.language),
                        label: const Text('Exploratia'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdministrationCard extends StatelessWidget {
  const _AdministrationCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
