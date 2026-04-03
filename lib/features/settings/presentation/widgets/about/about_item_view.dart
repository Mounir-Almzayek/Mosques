import 'package:flutter/material.dart';
import '../../../../../data/models/about_section_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutItemView extends StatelessWidget {
  final AboutSectionModel section;

  const AboutItemView({super.key, required this.section});

  Future<void> _launchURL() async {
    final uri = Uri.parse(section.content);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final fontWeight = section.fontWeight == AboutSectionWeight.bold
        ? FontWeight.bold
        : FontWeight.normal;

    final style = theme.textTheme.bodyMedium?.copyWith(
          fontSize: section.fontSize,
          fontWeight: fontWeight,
        ) ??
        TextStyle(fontSize: section.fontSize, fontWeight: fontWeight);

    switch (section.type) {
      case AboutSectionType.text:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.description_outlined, size: 20, color: primary),
              const SizedBox(width: 12),
              Expanded(child: Text(section.content, style: style)),
            ],
          ),
        );

      case AboutSectionType.link:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            onTap: _launchURL,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.link_rounded, size: 20, color: primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section.content,
                      style: style.copyWith(
                        color: primary,
                        decoration: TextDecoration.underline,
                        decorationColor: primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case AboutSectionType.qr:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: QrImageView(
                  data: section.content,
                  version: QrVersions.auto,
                  size: 160.0,
                  gapless: false,
                  // QR foreground uses theme primary
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: primary,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                section.content,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: primary.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
    }
  }
}
