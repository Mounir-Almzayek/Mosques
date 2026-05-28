import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/mosque/mosque_model.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'announcements_event.dart';
import 'announcements_state.dart';

export 'announcements_event.dart';
export 'announcements_state.dart';

class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  final IMosqueRepository _repo;

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
          emit(state.copyWith(isLoading: false, error: error.toString())),
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
    final list = List<AnnouncementModel>.from(m.announcements)
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
    emit(state.copyWith(isSaving: true));
    try {
      await _repo.updateAnnouncements(m);
      emit(
        state.copyWith(isSaving: false, hasUnsavedChanges: false, error: null),
      );
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
