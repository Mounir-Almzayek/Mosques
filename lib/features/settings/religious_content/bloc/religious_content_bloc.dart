import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/error_mapper.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../data/models/mosque/mosque_bootstrap.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'religious_content_event.dart';
import 'religious_content_state.dart';

export 'religious_content_event.dart';
export 'religious_content_state.dart';

class ReligiousContentBloc
    extends Bloc<ReligiousContentEvent, ReligiousContentState> {
  final IMosqueRepository _repo;
  final AsyncRunner<void> _saveRunner = AsyncRunner();

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
          emit(state.copyWith(isLoading: false, error: errorMessage(error))),
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

  /// Backend `kind` strings that map to a given [MosqueTextListKind]. Mirrors
  /// the kind-sets used by [MosqueBootstrap.listByKind].
  static Set<String> _kindStrings(MosqueTextListKind kind) {
    switch (kind) {
      case MosqueTextListKind.hadith:
        return const {'hadith'};
      case MosqueTextListKind.verse:
        return const {'ayah', 'verse'};
      case MosqueTextListKind.dua:
        return const {'dua'};
      case MosqueTextListKind.adhkar:
        return const {'dhikr', 'adhkar'};
    }
  }

  /// Rebuilds the full `content` list as the items of every *other* kind plus
  /// [list] (the edited items of [kind]).
  MosqueBootstrap _mosqueWithTextList(
    MosqueBootstrap m,
    MosqueTextListKind kind,
    List<ContentItem> list,
  ) {
    final kinds = _kindStrings(kind);
    final others = m.content.where((c) => !kinds.contains(c.kind)).toList();
    return m.copyWith(content: [...others, ...list]);
  }

  void _onMosqueTextAdded(
    MosqueTextAdded event,
    Emitter<ReligiousContentState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final list = List<ContentItem>.from(m.listByKind(event.kind))
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
      ReligiousContentTimingField.wait => m.displaySettings.copyWith(
        religiousContentWaitSeconds: event.value,
      ),
      ReligiousContentTimingField.display => m.displaySettings.copyWith(
        religiousContentDisplaySeconds: event.value,
      ),
    };
    emit(
      state.copyWith(
        mosque: m.copyWith(displaySettings: d),
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
    await _saveRunner.run(
      checkConnectivity: false,
      onlineTask: (_) async {
        for (final kind in MosqueTextListKind.values) {
          await _repo.updateMosqueTextList(m, kind);
        }
        await _repo.updateDesignSettings(m);
      },
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
