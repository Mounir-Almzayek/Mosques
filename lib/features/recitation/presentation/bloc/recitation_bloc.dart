import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/mosque/imam_tracking_session_model.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../data/models/tracked_verse.dart';
import '../../data/repositories/interfaces/imam_tracking_repository_interface.dart';
import '../../data/services/imam_audio_recorder.dart';
import 'recitation_event.dart';
import 'recitation_state.dart';

class ImamTrackingBloc extends Bloc<ImamTrackingEvent, ImamTrackingState> {
  final IImamTrackingRepository repository;
  final IMosqueRepository mosqueRepository;
  final ImamAudioRecorder audioRecorder;
  Timer? _trackingTimer;
  StreamSubscription<dynamic>? _mosqueSubscription;

  ImamTrackingBloc({
    required this.repository,
    required this.mosqueRepository,
    required this.audioRecorder,
  }) : super(const ImamTrackingState()) {
    on<LoadImamTracking>(_onLoadImamTracking);
    on<ToggleRecording>(_onToggleRecording);
    on<StartImamDisplay>(_onStartImamDisplay);
    on<StopImamDisplay>(_onStopImamDisplay);
    on<ImamTrackingSessionUpdated>(_onSessionUpdated);
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
    _mosqueSubscription?.cancel();
    _mosqueSubscription = mosqueRepository.streamActiveMosque.listen((mosque) {
      if (mosque != null && !isClosed) {
        add(ImamTrackingSessionUpdated(mosque.imamTrackingSession));
      }
    });
    emit(
      state.copyWith(
        currentPage: lastPage,
        currentVerseIndex: 0,
        isLoading: false,
      ),
    );
  }

  Future<void> _onStartImamDisplay(
    StartImamDisplay event,
    Emitter<ImamTrackingState> emit,
  ) async {
    emit(state.copyWith(isPublishing: true, publishError: null));
    try {
      await audioRecorder.start();
    } catch (_) {
      emit(
        state.copyWith(
          isPublishing: false,
          isRecording: false,
          isDisplayActive: false,
          publishError: 'تعذر بدء تسجيل الصوت. تحقق من إذن الميكروفون.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isDisplayActive: true,
        isRecording: true,
        isPublishing: true,
        publishError: null,
        lastRecordedAt: DateTime.now(),
      ),
    );
    _startTrackingTimer();
    await _publishState(emit);
  }

  Future<void> _onStopImamDisplay(
    StopImamDisplay event,
    Emitter<ImamTrackingState> emit,
  ) async {
    _trackingTimer?.cancel();
    await audioRecorder.stop();
    emit(
      state.copyWith(
        isDisplayActive: false,
        isRecording: false,
        isPublishing: true,
        publishError: null,
        lastRecordedAt: DateTime.now(),
      ),
    );
    await _publishState(emit);
  }

  void _onSessionUpdated(
    ImamTrackingSessionUpdated event,
    Emitter<ImamTrackingState> emit,
  ) {
    final session = event.session;
    if (!session.isActive &&
        !state.isDisplayActive &&
        session.trackedVerses.isEmpty) {
      return;
    }

    if (!session.isActive) {
      _trackingTimer?.cancel();
      unawaited(audioRecorder.stop());
    } else if (session.isRecording && !state.isRecording) {
      _startTrackingTimer();
    }

    emit(
      state.copyWith(
        currentPage: session.currentPage,
        isDisplayActive: session.isActive,
        isRecording: session.isRecording,
        clearHighlightedVerse: session.highlightedVerse == null,
        highlightedVerse: session.highlightedVerse == null
            ? null
            : TrackedVerse(
                surahNumber: session.highlightedVerse!.surahNumber,
                verseNumber: session.highlightedVerse!.verseNumber,
                pageNumber: session.highlightedVerse!.pageNumber,
                status: TrackedVerseStatus.read,
              ),
        trackedVerses: session.trackedVerses
            .map(
              (verse) => TrackedVerse(
                surahNumber: verse.surahNumber,
                verseNumber: verse.verseNumber,
                pageNumber: verse.pageNumber,
                status: verse.isIncorrect
                    ? TrackedVerseStatus.incorrect
                    : TrackedVerseStatus.read,
              ),
            )
            .toList(),
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
      if (state.isDisplayActive) {
        unawaited(_publishSilently());
      }
      return;
    }

    emit(state.copyWith(isRecording: true, lastRecordedAt: DateTime.now()));
    _startTrackingTimer();
    if (state.isDisplayActive) {
      unawaited(_publishSilently());
    }
  }

  void _startTrackingTimer() {
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
    if (state.isDisplayActive) {
      unawaited(_publishSilently());
    }
  }

  Future<void> _onAdvanceHighlightedVerse(
    AdvanceHighlightedVerse event,
    Emitter<ImamTrackingState> emit,
  ) async {
    final pageVerses = repository.getPageVerses(state.currentPage);
    if (pageVerses.isEmpty) return;

    final currentIndex = state.currentVerseIndex.clamp(
      0,
      pageVerses.length - 1,
    );
    final highlightedVerse = pageVerses[currentIndex];
    final nextIndex = currentIndex + 1;

    if (nextIndex >= pageVerses.length) {
      _trackingTimer?.cancel();
      await audioRecorder.stop();
      emit(
        state.copyWith(
          highlightedVerse: highlightedVerse,
          isRecording: false,
          lastRecordedAt: DateTime.now(),
        ),
      );
      if (state.isDisplayActive) {
        unawaited(_publishSilently());
      }
      return;
    }

    emit(
      state.copyWith(
        highlightedVerse: highlightedVerse,
        currentVerseIndex: nextIndex,
      ),
    );
    if (state.isDisplayActive) {
      unawaited(_publishSilently());
    }
  }

  void _onMarkVerseRead(MarkVerseRead event, Emitter<ImamTrackingState> emit) {
    emit(
      state.copyWith(
        highlightedVerse: TrackedVerse(
          surahNumber: event.surahNumber,
          verseNumber: event.verseNumber,
          pageNumber: state.currentPage,
          status: TrackedVerseStatus.read,
        ),
      ),
    );
    if (state.isDisplayActive) {
      unawaited(_publishSilently());
    }
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
    if (state.isDisplayActive) {
      unawaited(_publishSilently());
    }
  }

  ImamTrackingSessionModel _sessionFromState() {
    return ImamTrackingSessionModel(
      isActive: state.isDisplayActive,
      isRecording: state.isRecording,
      currentPage: state.currentPage,
      highlightedVerse: state.highlightedVerse == null
          ? null
          : ImamTrackingVerseModel(
              surahNumber: state.highlightedVerse!.surahNumber,
              verseNumber: state.highlightedVerse!.verseNumber,
              pageNumber: state.highlightedVerse!.pageNumber,
            ),
      trackedVerses: state.trackedVerses
          .map(
            (verse) => ImamTrackingVerseModel(
              surahNumber: verse.surahNumber,
              verseNumber: verse.verseNumber,
              pageNumber: verse.pageNumber,
              isIncorrect: verse.status == TrackedVerseStatus.incorrect,
            ),
          )
          .toList(),
    );
  }

  Future<void> _publishCurrentState() {
    return mosqueRepository.updateImamTrackingSession(_sessionFromState());
  }

  Future<void> _publishSilently() async {
    try {
      await _publishCurrentState();
    } catch (_) {
      // The explicit start/stop actions surface publishing errors in state.
    }
  }

  Future<void> _publishState(Emitter<ImamTrackingState> emit) async {
    try {
      await _publishCurrentState();
      emit(state.copyWith(isPublishing: false, publishError: null));
    } catch (error) {
      emit(
        state.copyWith(
          isPublishing: false,
          publishError: 'تعذر تحديث شاشة العرض',
        ),
      );
    }
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
    _mosqueSubscription?.cancel();
    unawaited(audioRecorder.dispose());
    return super.close();
  }
}
