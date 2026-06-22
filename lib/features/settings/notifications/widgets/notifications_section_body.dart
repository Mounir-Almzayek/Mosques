import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../data/models/notification_inbox_item.dart';
import '../bloc/notifications_bloc.dart';

class NotificationsSectionBody extends StatelessWidget {
  const NotificationsSectionBody({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<NotificationsBloc, NotificationsState>(
      listener: (context, state) {
        if (state.error != null) {
          UnifiedSnackbar.error(context, message: state.error!);
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Text(
                s.notifications_empty,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            context.read<NotificationsBloc>().add(const RefreshNotifications());
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _NotificationCard(
                item: item,
                onTap: () => _openDetails(context, item),
              );
            },
          ),
        );
      },
    );
  }

  void _openDetails(BuildContext context, NotificationInboxItem item) {
    if (!item.isRead) {
      context.read<NotificationsBloc>().add(
        MarkNotificationReadRequested(item.messageId),
      );
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _NotificationDetailsSheet(item: item),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final NotificationInboxItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !item.isRead;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: unread ? AppColors.primaryWhisper : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unread ? AppColors.primarySurface : AppColors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.notifications_none, color: Colors.white),
                  ),
                  if (unread)
                    PositionedDirectional(
                      end: -1,
                      top: -1,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: unread ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                unread
                    ? S.of(context).notifications_unread
                    : S.of(context).notifications_read,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: unread ? AppColors.primary : AppColors.secondaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationDetailsSheet extends StatelessWidget {
  const _NotificationDetailsSheet({required this.item});

  final NotificationInboxItem item;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          6,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: SelectableText(
                  item.body,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.65,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: '${item.title}\n\n${item.body}'),
                );
                if (!context.mounted) return;
                UnifiedSnackbar.success(
                  context,
                  message: s.notifications_copied,
                );
              },
              icon: const Icon(Icons.copy_rounded),
              label: Text(s.copy),
            ),
          ],
        ),
      ),
    );
  }
}
