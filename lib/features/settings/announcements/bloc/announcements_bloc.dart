import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/error_mapper.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../data/models/mosque/mosque_bootstrap.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'announcements_event.dart';
import 'announcements_state.dart';

export 'announcements_event.dart';
export 'announcements_state.dart';

class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  final IMosqueRepository _repo;
  final AsyncRunner<void> _saveRunner = AsyncRunner();

  AnnouncementsBloc({required IMosqueRepository mosqueRepository})
    : _repo = mosqueRepository,
      super(const AnnouncementsState()) {
    on<LoadAnnouncements>(_onLoad);
    on<AnnouncementsMosqueUpdated>(_onMosqueUpdated);
    on<AnnouncementAdded>(_onAnnouncementAdded);
    on<AnnouncementUpdated>(_onAnnouncementUpdated);
    on<AnnouncementRemoved>(_onAnnouncementRemoved);
    on<SaveAnnouncementsRequested>(_onSave);
  }

  StreamSubscription<dynamic>? _sub;

  Future<void> _onLoad(
    LoadAnnouncements event,
    Emitter<AnnouncementsState> emit,
  ) async {
    _sub?.cancel();
    emit(state.copyWith(isLoading: true));
    _sub = _repo.streamActiveMosque.listen(
      (mosque) => add(AnnouncementsMosqueUpdated(mosque)),
      onError: (Object error) =>
          emit(state.copyWith(isLoading: false, error: errorMessage(error))),
    );
  }

  void _onMosqueUpdated(
    AnnouncementsMosqueUpdated event,
    Emitter<AnnouncementsState> emit,
  ) {
    if (!state.hasUnsavedChanges) {
      emit(
        state.copyWith(
          isLoading: false,
          mosque: event.mosque,
          hasUnsavedChanges: false,
        ),
      );
    } else {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onAnnouncementAdded(
    AnnouncementAdded event,
    Emitter<AnnouncementsState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final list = List<Announcement>.from(m.announcements)
      ..add(event.announcement);
    emit(
      state.copyWith(
        mosque: m.copyWith(announcements: list),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onAnnouncementUpdated(
    AnnouncementUpdated event,
    Emitter<AnnouncementsState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final list = m.announcements
        .map((a) => a.id == event.announcement.id ? event.announcement : a)
        .toList();
    emit(
      state.copyWith(
        mosque: m.copyWith(announcements: list),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onAnnouncementRemoved(
    AnnouncementRemoved event,
    Emitter<AnnouncementsState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final list = m.announcements
        .where((a) => a.id != event.announcementId)
        .toList();
    emit(
      state.copyWith(
        mosque: m.copyWith(announcements: list),
        hasUnsavedChanges: true,
      ),
    );
  }

  Future<void> _onSave(
    SaveAnnouncementsRequested event,
    Emitter<AnnouncementsState> emit,
  ) async {
    final m = state.mosque;
    if (m == null) return;
    // Persist edited ads (non-alert announcements) while preserving any
    // saved alerts unchanged — announcements + alerts share one list now.
    final updated = m.copyWith(
      announcements: [...m.ads, ...m.savedAlerts],
    );
    await _saveRunner.run(
      checkConnectivity: false,
      onlineTask: (_) => _repo.updateAnnouncements(updated),
      onStart: () => emit(state.copyWith(isSaving: true)),
      onSuccess: (_) => emit(
        state.copyWith(isSaving: false, hasUnsavedChanges: false, error: null),
      ),
      onError: (error) =>
          emit(state.copyWith(isSaving: false, error: errorMessage(error))),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _saveRunner.cancel();
    return super.close();
  }
}
