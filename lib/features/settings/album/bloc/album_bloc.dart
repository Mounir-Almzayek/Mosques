import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/error_mapper.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'album_event.dart';
import 'album_state.dart';

export 'album_event.dart';
export 'album_state.dart';

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final IMosqueRepository _repo;
  final AsyncRunner<void> _saveRunner = AsyncRunner();

  AlbumBloc({required IMosqueRepository mosqueRepository})
    : _repo = mosqueRepository,
      super(const AlbumState()) {
    on<LoadAlbum>(_onLoad);
    on<AlbumMosqueUpdated>(_onMosqueUpdated);
    on<AlbumImageAdded>(_onImageAdded);
    on<AlbumImageRemoved>(_onImageRemoved);
    on<AlbumImagePublished>(_onImagePublished);
    on<AlbumImageUnpublished>(_onImageUnpublished);
    on<SaveAlbumRequested>(_onSave);
    on<DiscardAlbumChangesRequested>(_onDiscardChanges);
  }

  StreamSubscription<dynamic>? _sub;

  Future<void> _onLoad(LoadAlbum event, Emitter<AlbumState> emit) async {
    _sub?.cancel();
    emit(state.copyWith(isLoading: true));
    _sub = _repo.streamActiveMosque.listen(
      (mosque) => add(AlbumMosqueUpdated(mosque)),
      onError: (Object error) =>
          emit(state.copyWith(isLoading: false, error: errorMessage(error))),
    );
  }

  void _onMosqueUpdated(AlbumMosqueUpdated event, Emitter<AlbumState> emit) {
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

  void _onImageAdded(AlbumImageAdded event, Emitter<AlbumState> emit) {
    final m = state.mosque;
    if (m == null) return;
    final urls = [...m.displaySettings.albumImageUrls, event.url];
    emit(
      state.copyWith(
        mosque: m.copyWith(
          displaySettings: m.displaySettings.copyWith(albumImageUrls: urls),
        ),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onImageRemoved(AlbumImageRemoved event, Emitter<AlbumState> emit) {
    final m = state.mosque;
    if (m == null) return;
    final urls = m.displaySettings.albumImageUrls
        .where((u) => u != event.url)
        .toList();
    emit(
      state.copyWith(
        mosque: m.copyWith(
          displaySettings: m.displaySettings.copyWith(albumImageUrls: urls),
        ),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onImagePublished(AlbumImagePublished event, Emitter<AlbumState> emit) {
    final m = state.mosque;
    if (m == null) return;
    emit(
      state.copyWith(
        mosque: m.copyWith(
          displaySettings: m.displaySettings.copyWith(
            publishedAlbumUrl: event.url,
            publishedAlbumAt: DateTime.now(),
            publishedAlbumDurationSeconds: event.durationSeconds,
            publishedAlbumFit: event.fit,
          ),
        ),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onImageUnpublished(
    AlbumImageUnpublished event,
    Emitter<AlbumState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    emit(
      state.copyWith(
        mosque: m.copyWith(
          displaySettings: m.displaySettings.copyWith(publishedAlbumUrl: ''),
        ),
        hasUnsavedChanges: true,
      ),
    );
  }

  Future<void> _onSave(
    SaveAlbumRequested event,
    Emitter<AlbumState> emit,
  ) async {
    final m = state.mosque;
    if (m == null) return;
    await _saveRunner.run(
      checkConnectivity: false,
      onlineTask: (_) => _repo.updateMosque(m),
      onStart: () => emit(state.copyWith(isSaving: true)),
      onSuccess: (_) => emit(
        state.copyWith(isSaving: false, hasUnsavedChanges: false, error: null),
      ),
      onError: (error) =>
          emit(state.copyWith(isSaving: false, error: errorMessage(error))),
    );
  }

  void _onDiscardChanges(
    DiscardAlbumChangesRequested event,
    Emitter<AlbumState> emit,
  ) {
    emit(state.copyWith(hasUnsavedChanges: false, error: null));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _saveRunner.cancel();
    return super.close();
  }
}
