import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/settings/announcement_schedule.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../data/models/mosque/mosque_bootstrap.dart';
import '../bloc/announcements_bloc.dart';
import 'announcement_editor_sheet.dart';
import 'announcement_empty_state.dart';
import 'announcement_list_item.dart';
import 'announcement_save_bar.dart';

class AnnouncementSectionBody extends StatefulWidget {
  const AnnouncementSectionBody({super.key});

  @override
  State<AnnouncementSectionBody> createState() =>
      _AnnouncementSectionBodyState();
}

class _AnnouncementSectionBodyState extends State<AnnouncementSectionBody> {
  AnnouncementSchedule _scheduleFor(Announcement announcement) {
    final now = DateTime.now();
    if (now.isBefore(announcement.startAt)) {
      return AnnouncementSchedule.upcoming;
    }
    if (!now.isBefore(announcement.endAt)) {
      return AnnouncementSchedule.ended;
    }
    return AnnouncementSchedule.active;
  }

  void _save() {
    context.read<AnnouncementsBloc>().add(const SaveAnnouncementsRequested());
  }

  Future<void> _confirmDelete(Announcement announcement) async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.announcement_delete_title),
        content: Text(s.announcement_delete_body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<AnnouncementsBloc>().add(
        AnnouncementRemoved(announcement.id),
      );
    }
  }

  Future<void> _openEditor([Announcement? existing]) async {
    final bloc = context.read<AnnouncementsBloc>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => AnnouncementEditorSheet(existing: existing, bloc: bloc),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<AnnouncementsBloc, AnnouncementsState>(
      listenWhen: (prev, curr) =>
          prev.isSaving != curr.isSaving ||
          (curr.error != null && prev.error == null),
      listener: (context, state) {
        if (state.isSaving) {
          UnifiedSnackbar.info(context, message: s.saving);
        } else if (state.error != null) {
          UnifiedSnackbar.error(context, message: state.error!);
        } else {
          UnifiedSnackbar.hide(context);
          UnifiedSnackbar.success(context, message: s.saved_successfully);
        }
      },
      child: BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
        builder: (context, state) {
          final mosque = state.mosque;
          if (mosque == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final announcements = mosque.ads;

          return Stack(
            fit: StackFit.expand,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (announcements.isEmpty)
                    Expanded(child: AnnouncementEmptyState(s: s))
                  else
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        itemCount: announcements.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final announcement = announcements[index];
                          return AnnouncementListItem(
                            announcement: announcement,
                            status: _scheduleFor(announcement),
                            s: s,
                            onActiveChanged: (value) {
                              context.read<AnnouncementsBloc>().add(
                                AnnouncementUpdated(
                                  announcement.copyWith(isActive: value),
                                ),
                              );
                            },
                            onEdit: () => _openEditor(announcement),
                            onDelete: () => _confirmDelete(announcement),
                          );
                        },
                      ),
                    ),
                  AnnouncementSaveBar(s: s, onSave: _save),
                ],
              ),
              Positioned(
                right: 16,
                bottom: 120,
                child: FloatingActionButton.extended(
                  heroTag: 'settings_announcement_fab',
                  onPressed: () => _openEditor(),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(s.announcement_fab_add),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
