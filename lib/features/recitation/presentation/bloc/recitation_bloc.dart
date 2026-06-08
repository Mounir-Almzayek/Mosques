import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/tracked_verse.dart';
import '../../data/repositories/interfaces/imam_tracking_repository_interface.dart';
import 'recitation_event.dart';
import 'recitation_state.dart';

class ImamTrackingBloc extends Bloc<ImamTrackingEvent, ImamTrackingState> {
  final IImamTrackingRepository repository;
  Timer? _trackingTimer;

  ImamTrackingBloc({required this.repository})
    : super(const ImamTrackingState()) {
    on<LoadImamTracking>(_onLoadImamTracking);
    on<ToggleRecording>(_onToggleRecording);
    on<SelectPage>(_onSelectPage);
    on<AdvanceHighlightedVerse>(_onAdvanceHighlightedVerse);
    on<MarkVerseRead>(_onMarkVerseRead);
    on<MarkVerseIncorrect>(_onMarkVerseIncorrect);
  }

  Future<void> _onLoadImamTracking(
    LoadImamTracking event,
    Emitter<ImamTrackingState> emit,
  ) async {
    final lastPage = await repository.getLastPage();
    emit(
      state.copyWith(
        currentPage: lastPage,
        currentVerseIndex: 0,
        isLoading: false,
      ),
    );
  }

  void _onToggleRecording(
    ToggleRecording event,
    Emitter<ImamTrackingState> emit,
  ) {
    if (state.isRecording) {
      _trackingTimer?.cancel();
      emit(state.copyWith(isRecording: false, lastRecordedAt: DateTime.now()));
      return;
    }

    emit(state.copyWith(isRecording: true, lastRecordedAt: DateTime.now()));
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const AdvanceHighlightedVerse()),
    );
  }

  Future<void> _onSelectPage(
    SelectPage event,
    Emitter<ImamTrackingState> emit,
  ) async {
    _trackingTimer?.cancel();
    await repository.saveLastPage(event.pageNumber);
    emit(
      state.copyWith(
        currentPage: event.pageNumber,
        currentVerseIndex: 0,
        isRecording: false,
      ),
    );
  }

  void _onAdvanceHighlightedVerse(
    AdvanceHighlightedVerse event,
    Emitter<ImamTrackingState> emit,
  ) {
    final pageVerses = repository.getPageVerses(state.currentPage);
    if (pageVerses.isEmpty) return;

    final currentIndex = state.currentVerseIndex.clamp(
      0,
      pageVerses.length - 1,
    );
    final trackedVerses = _upsertVerse(
      state.trackedVerses,
      pageVerses[currentIndex],
    );
    final nextIndex = currentIndex + 1;

    if (nextIndex >= pageVerses.length) {
      _trackingTimer?.cancel();
      emit(
        state.copyWith(
          trackedVerses: trackedVerses,
          isRecording: false,
          lastRecordedAt: DateTime.now(),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        trackedVerses: trackedVerses,
        currentVerseIndex: nextIndex,
      ),
    );
  }

  void _onMarkVerseRead(MarkVerseRead event, Emitter<ImamTrackingState> emit) {
    _markVerse(
      emit,
      event.surahNumber,
      event.verseNumber,
      TrackedVerseStatus.read,
    );
  }

  void _onMarkVerseIncorrect(
    MarkVerseIncorrect event,
    Emitter<ImamTrackingState> emit,
  ) {
    _markVerse(
      emit,
      event.surahNumber,
      event.verseNumber,
      TrackedVerseStatus.incorrect,
    );
  }

  void _markVerse(
    Emitter<ImamTrackingState> emit,
    int surahNumber,
    int verseNumber,
    TrackedVerseStatus status,
  ) {
    final verse = TrackedVerse(
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      pageNumber: state.currentPage,
      status: status,
    );
    emit(
      state.copyWith(trackedVerses: _upsertVerse(state.trackedVerses, verse)),
    );
  }

  List<TrackedVerse> _upsertVerse(
    List<TrackedVerse> verses,
    TrackedVerse verse,
  ) {
    return [...verses.where((item) => item.id != verse.id), verse];
  }

  @override
  Future<void> close() {
    _trackingTimer?.cancel();
    return super.close();
  }
}
