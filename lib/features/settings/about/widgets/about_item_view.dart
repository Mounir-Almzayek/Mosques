import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/utils/color_extensions.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../data/models/about/about_section_model.dart';

class AboutItemView extends StatelessWidget {
  static const EdgeInsets _sectionPadding = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets _qrSectionPadding = EdgeInsets.symmetric(
    vertical: 16,
  );
  static const double _linkIconSize = 20;
  static const double _qrImageSize = 160;

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
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        final fallbackLaunched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );

        if (!fallbackLaunched && context.mounted) {
          UnifiedSnackbar.warning(context, message: s.error_occurred);
        }
      }
    } catch (_) {
      if (!context.mounted) return;
      UnifiedSnackbar.error(context, message: s.error_occurred);
    }
  }

  TextStyle _baseStyle(ThemeData theme) {
    final fontWeight = section.fontWeight == AboutSectionWeight.bold
        ? FontWeight.bold
        : FontWeight.normal;

    return theme.textTheme.bodyMedium?.copyWith(
          fontSize: section.fontSize,
          fontWeight: fontWeight,
          color: Colors.black,
        ) ??
        TextStyle(
          fontSize: section.fontSize,
          fontWeight: fontWeight,
          color: Colors.black,
        );
  }

  Widget _buildTextSection(ThemeData theme) {
    final baseStyle = _baseStyle(theme);
    final lines = section.content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.length <= 1) {
      return Padding(
        padding: _sectionPadding,
        child: Text(
          section.content.trim(),
          textAlign: TextAlign.right,
          style: baseStyle,
        ),
      );
    }

    final titleText = lines.first;
    final bodyText = lines.sublist(1).join('\n');

    return Padding(
      padding: _sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(titleText, textAlign: TextAlign.right, style: baseStyle),
          const SizedBox(height: 4),
          Text(bodyText, textAlign: TextAlign.right, style: baseStyle),
        ],
      ),
    );
  }

  Widget _buildLinkSection(BuildContext context, TextStyle style) {
    return Padding(
      padding: _sectionPadding,
      child: InkWell(
        onTap: () => _launchUrl(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                Icons.link_rounded,
                size: _linkIconSize,
                color: Colors.black,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.content.trim(),
                  textAlign: TextAlign.right,
                  style: style.copyWith(
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrSection(ThemeData theme) {
    return Padding(
      padding: _qrSectionPadding,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacityCompat(0.3),
                width: 1.5,
              ),
            ),
            child: QrImageView(
              data: section.content,
              version: QrVersions.auto,
              size: _qrImageSize,
              gapless: false,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: theme.colorScheme.primary,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section.content.trim(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _baseStyle(theme);

    switch (section.type) {
      case AboutSectionType.text:
        return _buildTextSection(theme);
      case AboutSectionType.link:
        return _buildLinkSection(context, style);
      case AboutSectionType.qr:
        return _buildQrSection(theme);
    }
  }
}
