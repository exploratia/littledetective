import 'package:flutter/material.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoDocumentScreen extends StatelessWidget {
  const InfoDocumentScreen({
    required this.title,
    required this.assetPath,
    super.key,
  });

  final String title;
  final String assetPath;

  void _openLink(dynamic link) {
    final href = link?.toString();
    if (href == null || href.trim().isEmpty) {
      return;
    }
    final url = Uri.tryParse(href);
    if (url == null) {
      return;
    }
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  String _adaptHtmlForLittleDetective(String html) {
    return html
        .replaceAll('xTracker', 'Little Detective')
        .replaceAll('xtracker', 'littledetective')
        .replaceAll(
          'www.exploratia.de/littledetective.php',
          'https://github.com/exploratia/littledetective',
        );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final defaultTextStyle = TextStyle(
      color: themeData.textTheme.bodyMedium?.color,
      fontSize: themeData.textTheme.bodyMedium?.fontSize,
      height: themeData.textTheme.bodyMedium?.height,
    );
    final overrideStyle = {
      'a': TextStyle(
        color: themeData.colorScheme.primary,
        fontWeight: themeData.textTheme.bodyMedium?.fontWeight,
      ),
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(assetPath),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load document.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: HTML.toRichText(
              context,
              _adaptHtmlForLittleDetective(snapshot.data!),
              defaultTextStyle: defaultTextStyle,
              overrideStyle: overrideStyle,
              linksCallback: (link) => _openLink(link),
            ),
          );
        },
      ),
    );
  }
}
