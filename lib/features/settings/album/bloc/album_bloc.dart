import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'album_event.dart';
import 'album_state.dart';

export 'album_event.dart';
export 'album_state.dart';

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final IMosqueRepository _repo;

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
  }

  StreamSubscription<dynamic>? _sub;

  Future<void> _onLoad(LoadAlbum event, Emitter<AlbumState> emit) async {
    _sub?.cancel();
    emit(state.copyWith(isLoading: true));
    _sub = _repo.streamActiveMosque.listen(
      (mosque) => add(AlbumMosqueUpdated(mosque)),
      onError: (Object error) =>
          emit(state.copyWith(isLoading: false, error: error.toString())),
    );
  }

  void _onMosqueUpdated(AlbumMosqueUpdated event, Emitter<AlbumState> emit) {
    if (!state.hasUnsavedChanges) {
      emit(state.copyWith(
        isLoading: false,
        mosque: event.mosque,
        hasUnsavedChanges: false,
      ));
    } else {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onImageAdded(AlbumImageAdded event, Emitter<AlbumState> emit) {
    final m = state.mosque;
    if (m == null) return;
    final urls = [...m.albumImageUrls, event.url];
    emit(state.copyWith(
      mosque: m.copyWith(albumImageUrls: urls),
      hasUnsavedChanges: true,
    ));
  }

  void _onImageRemoved(AlbumImageRemoved event, Emitter<AlbumState> emit) {
    final m = state.mosque;
    if (m == null) return;
    final urls = m.albumImageUrls.where((u) => u != event.url).toList();
    emit(state.copyWith(
      mosque: m.copyWith(albumImageUrls: urls),
      hasUnsavedChanges: true,
    ));
  }

  void _onImagePublished(
    AlbumImagePublished event,
    Emitter<AlbumState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    emit(state.copyWith(
      mosque: m.copyWith(
        publishedAlbumImageUrl: event.url,
        publishedAlbumImageAt: DateTime.now(),
        publishedAlbumImageDuration: event.durationSeconds,
      ),
      hasUnsavedChanges: true,
    ));
  }

  void _onImageUnpublished(
    AlbumImageUnpublished event,
    Emitter<AlbumState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    emit(state.copyWith(
      mosque: m.copyWith(publishedAlbumImageUrl: ''),
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onSave(
    SaveAlbumRequested event,
    Emitter<AlbumState> emit,
  ) async {
    final m = state.mosque;
    if (m == null) return;
    emit(state.copyWith(isSaving: true));
    try {
      await _repo.updateMosque(m);
      emit(state.copyWith(
        isSaving: false,
        hasUnsavedChanges: false,
        error: null,
      ));
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
