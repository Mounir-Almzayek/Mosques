import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../../data/models/about/about_section_model.dart';

class AboutItemView extends StatelessWidget {
  final AboutSectionModel section;

  const AboutItemView({super.key, required this.section});

  Uri? _normalizeUri(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final direct = Uri.tryParse(trimmed);
    if (direct != null && direct.hasScheme) {
      return direct;
    }

    return Uri.tryParse('https://$trimmed');
  }

  Future<void> _launchUrl(BuildContext context) async {
    final uri = _normalizeUri(section.content);
    final s = S.of(context);

    if (uri == null) {
      UnifiedSnackbar.warning(context, message: s.error_occurred);
      return;
    }

    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return;
      }
      if (await launchUrl(uri, mode: LaunchMode.platformDefault)) {
        return;
      }
      if (!context.mounted) return;
      UnifiedSnackbar.warning(context, message: s.error_occurred);
    } catch (_) {
      if (!context.mounted) return;
      UnifiedSnackbar.error(context, message: s.error_occurred);
    }
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
            onTap: () => _launchUrl(context),
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
