import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../data/models/platform_announcements/settings_announcement_model.dart';
import '../../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../../../data/repositories/interfaces/platform_announcements_repository_interface.dart';
import '../../../auth/models/auth_user.dart';

class GeneralSectionBody extends StatelessWidget {
  const GeneralSectionBody({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final user = sl<IAuthRepository>().currentUser;
    final settingsAnnouncementsStream = sl<IPlatformAnnouncementsRepository>()
        .watchSettingsAnnouncements();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AccountOverviewCard(user: user),
        const SizedBox(height: 20),
        Text(
          s.settings_app_announcements_title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<SettingsAnnouncementModel>>(
          stream: settingsAnnouncementsStream,
          builder: (context, snapshot) {
            final announcements =
                snapshot.data ?? const <SettingsAnnouncementModel>[];
            if (announcements.isEmpty) {
              return _AnnouncementsEmptyState(
                message: s.general_no_announcements,
              );
            }
            return Column(
              children: announcements
                  .map(
                    (announcement) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SettingsAnnouncementCard(
                        announcement: announcement,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _AccountOverviewCard extends StatelessWidget {
  const _AccountOverviewCard({required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final name = user?.fullName?.trim();
    final title = name == null || name.isEmpty ? user?.email ?? '...' : name;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.general_account_title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if ((user?.email ?? '').isNotEmpty && title != user?.email)
                    Text(
                      user!.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                      ),
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

class _SettingsAnnouncementCard extends StatelessWidget {
  const _SettingsAnnouncementCard({required this.announcement});

  final SettingsAnnouncementModel announcement;

  Future<void> _openLink() async {
    final raw = announcement.linkUrl?.trim();
    if (raw == null || raw.isEmpty) return;
    final uri = Uri.tryParse(raw);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final hasLink = announcement.hasLink;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: hasLink ? _openLink : null,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryWhisper,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryText,
                      ),
                    ),
                    if (announcement.hasBody) ...[
                      const SizedBox(height: 6),
                      Text(
                        announcement.body!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasLink)
                const Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: AppColors.secondaryText,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementsEmptyState extends StatelessWidget {
  const _AnnouncementsEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            const Icon(Icons.campaign_outlined, color: AppColors.secondaryText),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
