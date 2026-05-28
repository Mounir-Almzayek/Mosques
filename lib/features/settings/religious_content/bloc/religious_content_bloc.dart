import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/mosque/mosque_model.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'religious_content_event.dart';
import 'religious_content_state.dart';

export 'religious_content_event.dart';
export 'religious_content_state.dart';

class ReligiousContentBloc
    extends Bloc<ReligiousContentEvent, ReligiousContentState> {
  final IMosqueRepository _repo;

  ReligiousContentBloc({required IMosqueRepository mosqueRepository})
    : _repo = mosqueRepository,
      super(const ReligiousContentState()) {
    on<LoadReligiousContent>(_onLoad);
    on<ReligiousContentMosqueUpdated>(_onMosqueUpdated);
    on<MosqueTextAdded>(_onMosqueTextAdded);
    on<MosqueTextUpdated>(_onMosqueTextUpdated);
    on<MosqueTextRemoved>(_onMosqueTextRemoved);
    on<ReligiousContentTimingChanged>(_onTimingChanged);
    on<SaveAllReligiousContentRequested>(_onSaveAll);
  }

  StreamSubscription<dynamic>? _sub;

  Future<void> _onLoad(
    LoadReligiousContent event,
    Emitter<ReligiousContentState> emit,
  ) async {
    _sub?.cancel();
    emit(state.copyWith(isLoading: true));
    _sub = _repo.streamActiveMosque.listen(
      (mosque) => add(ReligiousContentMosqueUpdated(mosque)),
      onError: (Object error) =>
          emit(state.copyWith(isLoading: false, error: error.toString())),
    );
  }

  void _onMosqueUpdated(
    ReligiousContentMosqueUpdated event,
    Emitter<ReligiousContentState> emit,
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

  // ── Text List CRUD ──────────────────────────────────────────────────

  MosqueModel _mosqueWithTextList(
    MosqueModel m,
    MosqueTextListKind kind,
    List<MosqueTextEntryModel> list,
  ) {
    switch (kind) {
      case MosqueTextListKind.hadith:
        return m.copyWith(hadiths: list);
      case MosqueTextListKind.verse:
        return m.copyWith(verses: list);
      case MosqueTextListKind.dua:
        return m.copyWith(duas: list);
      case MosqueTextListKind.adhkar:
        return m.copyWith(adhkar: list);
    }
  }

  void _onMosqueTextAdded(
    MosqueTextAdded event,
    Emitter<ReligiousContentState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final list = List<MosqueTextEntryModel>.from(m.listByKind(event.kind))
      ..add(event.item);
    emit(
      state.copyWith(
        mosque: _mosqueWithTextList(m, event.kind, list),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onMosqueTextUpdated(
    MosqueTextUpdated event,
    Emitter<ReligiousContentState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final list = m
        .listByKind(event.kind)
        .map((h) => h.id == event.item.id ? event.item : h)
        .toList();
    emit(
      state.copyWith(
        mosque: _mosqueWithTextList(m, event.kind, list),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onMosqueTextRemoved(
    MosqueTextRemoved event,
    Emitter<ReligiousContentState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final list = m
        .listByKind(event.kind)
        .where((h) => h.id != event.itemId)
        .toList();
    emit(
      state.copyWith(
        mosque: _mosqueWithTextList(m, event.kind, list),
        hasUnsavedChanges: true,
      ),
    );
  }

  // ── Timing ──────────────────────────────────────────────────────────

  void _onTimingChanged(
    ReligiousContentTimingChanged event,
    Emitter<ReligiousContentState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = switch (event.field) {
      ReligiousContentTimingField.wait => m.designSettings.copyWith(
        religiousContentWaitSeconds: event.value,
      ),
      ReligiousContentTimingField.display => m.designSettings.copyWith(
        religiousContentDisplaySeconds: event.value,
      ),
    };
    emit(
      state.copyWith(
        mosque: m.copyWith(designSettings: d),
        hasUnsavedChanges: true,
      ),
    );
  }

  // ── Save All ────────────────────────────────────────────────────────

  Future<void> _onSaveAll(
    SaveAllReligiousContentRequested event,
    Emitter<ReligiousContentState> emit,
  ) async {
    final m = state.mosque;
    if (m == null) return;
    emit(state.copyWith(isSaving: true));
    try {
      for (final kind in MosqueTextListKind.values) {
        await _repo.updateMosqueTextList(m, kind);
      }
      await _repo.updateDesignSettings(m);
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
