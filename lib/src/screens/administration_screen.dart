import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'info_document_screen.dart';

class AdministrationScreen extends StatefulWidget {
  const AdministrationScreen({super.key});

  @override
  State<AdministrationScreen> createState() => _AdministrationScreenState();
}

class _AdministrationScreenState extends State<AdministrationScreen> {
  static const _appName = 'Little Detective';
  static const _legalNoticeAsset = 'assets/infos/legal_notice.html';
  static const _privacyPolicyAsset = 'assets/infos/privacy_policy.html';
  static const _disclaimerAsset = 'assets/infos/disclaimer.html';
  static const _eulaAsset = 'assets/infos/eula.html';

  static final Uri _buyMeACoffeeUri = Uri.parse('https://coff.ee/exploratia');
  static final Uri _githubUri = Uri.parse('https://github.com/exploratia/littledetective');
  static final Uri _githubIssueUri = Uri.parse('https://github.com/exploratia/littledetective/issues');
  static final Uri _exploratiaUri = Uri.parse('https://www.exploratia.de');
  static final Uri _exploratiaLittleDetectiveUri = Uri.parse('https://www.exploratia.de/littledetective.php');
  static final Uri _playstoreUri = Uri.parse('https://play.google.com/store/apps/details?id=de.exploratia.littledetective');

  void _openInfoDocument(BuildContext context, {required String title, required String assetPath}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InfoDocumentScreen(title: title, assetPath: assetPath),
      ),
    );
  }

  Future<void> _showVersionDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.buildNumber.trim().isEmpty ? packageInfo.version : '${packageInfo.version}+${packageInfo.buildNumber}';
    if (!context.mounted) {
      return;
    }
    showAboutDialog(
      context: context,
      applicationName: _appName,
      applicationVersion: version,
      applicationIcon: Image.asset('assets/app_icon.png', width: 64, height: 64, excludeFromSemantics: true),
      applicationLegalese: '${DateTime.now().year} \u00A9 Christian Adler',
    );
  }

  Future<void> _openLink(BuildContext context, Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open $uri')));
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
                  const Text('Maintaining and improving this app takes a lot of free time. Any support is appreciated.'),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _openLink(context, _buyMeACoffeeUri),
                    icon: const Icon(Icons.local_cafe_outlined),
                    label: const Text('Buy me a coffee'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _openLink(context, _playstoreUri),
                    icon: const Icon(Icons.rate_review_outlined),
                    label: const Text('Rate/Feedback in Google Play'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _openLink(context, _githubIssueUri),
                    icon: const Icon(Icons.bug_report_outlined),
                    label: const Text('Report a bug on GitHub'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _AdministrationCard(
              title: _appName,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Little Detective is a simple app with QR scanner and compass for kids.'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(onPressed: () => _showVersionDialog(context), icon: const Icon(Icons.info_outline), label: const Text('Version')),
                      OutlinedButton.icon(
                        onPressed: () => _openInfoDocument(context, title: 'Legal Notice', assetPath: _legalNoticeAsset),
                        icon: const Icon(Icons.gavel_outlined),
                        label: const Text('Legal Notice'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _openInfoDocument(context, title: 'Privacy Policy', assetPath: _privacyPolicyAsset),
                        icon: const Icon(Icons.privacy_tip_outlined),
                        label: const Text('Privacy Policy'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _openInfoDocument(context, title: 'Disclaimer', assetPath: _disclaimerAsset),
                        icon: const Icon(Icons.warning_amber_outlined),
                        label: const Text('Disclaimer'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _openInfoDocument(context, title: 'EULA', assetPath: _eulaAsset),
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('EULA'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _openLink(context, _githubUri),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Little Detective on GitHub'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _openLink(context, _exploratiaUri),
                        icon: const Icon(Icons.language),
                        label: const Text('Exploratia'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _openLink(context, _exploratiaLittleDetectiveUri),
                        icon: const Icon(Icons.language),
                        label: const Text('Little Detective on Exploratia'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Text('${DateTime.now().year} \u00A9 Christian Adler'),
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
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
