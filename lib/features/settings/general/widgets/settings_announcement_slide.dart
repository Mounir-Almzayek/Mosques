import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/platform_announcements/settings_announcement_model.dart';
import 'settings_announcement_image_badge.dart';

class SettingsAnnouncementSlide extends StatelessWidget {
  const SettingsAnnouncementSlide({super.key, required this.announcement});

  final SettingsAnnouncementModel announcement;

  Future<void> _openLink(BuildContext context) async {
    final raw = announcement.linkUrl?.trim();
    if (raw == null || raw.isEmpty) return;
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    if (uri.scheme != 'http' && uri.scheme != 'https') return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Ignore: opening links is best-effort.
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final hasImage = announcement.hasImage;
    final hasLink = announcement.hasLink;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final denseLayout = textScale > 1.1;
    final titleMaxLines = denseLayout && (hasImage || announcement.hasBody)
        ? 1
        : 2;
    final bodyMaxLines = denseLayout ? 1 : 2;
    final topPadding = denseLayout ? 40.0 : 46.0;

    final content = Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                scheme.primary,
                Color.lerp(scheme.primary, scheme.secondary, 0.45)!,
                scheme.tertiary.withValues(alpha: 0.92),
              ],
            ),
          ),
        ),
        if (hasImage)
          Positioned.fill(
            child: Image.network(
              announcement.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                colors: [
                  Colors.black.withValues(alpha: hasImage ? 0.68 : 0.32),
                  Colors.black.withValues(alpha: hasImage ? 0.34 : 0.12),
                  Colors.black.withValues(alpha: hasImage ? 0.08 : 0.04),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(18, topPadding, 18, 20),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasImage) ...[
                    SettingsAnnouncementImageBadge(
                      label: s.settings_app_announcements_image_badge,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    announcement.title.isNotEmpty
                        ? announcement.title
                        : s.settings_app_announcements_subtitle,
                    maxLines: titleMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                  if (announcement.hasBody) ...[
                    const SizedBox(height: 8),
                    Text(
                      announcement.body!,
                      maxLines: bodyMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (!hasLink) return content;

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openLink(context),
        child: content,
      ),
    );
  }
}
