import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';

import '../../../../core/enums/app_mode.dart';
import '../../../../core/services/error_mapper.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../core/widgets/quran/tracked_verse.dart';
import '../../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../data/recitation_ai_models.dart';
import '../data/recitation_ai_repository.dart';
import '../data/recitation_audio_streamer.dart';
import 'recitation_event.dart';
import 'recitation_state.dart';

class RecitationBloc extends Bloc<RecitationEvent, RecitationState> {
  final RecitationAiRepository _repository;
  final RecitationAudioStreamer _streamer;
  final IMosqueRepository _mosqueRepository;
  final IAuthRepository _authRepository;
  final AsyncRunner<_StartedRecitation> _startRunner = AsyncRunner(
    multipleCallsBehavior: MultipleCallsBehavior.abortOld,
  );
  final AsyncRunner<void> _stopRunner = AsyncRunner(
    multipleCallsBehavior: MultipleCallsBehavior.abortOld,
  );
  final AsyncRunner<void> _publishRunner = AsyncRunner(
    multipleCallsBehavior: MultipleCallsBehavior.abortOld,
  );

  RecitationBloc({
    required RecitationAiRepository repository,
    required RecitationAudioStreamer streamer,
    required IMosqueRepository mosqueRepository,
    required IAuthRepository authRepository,
  }) : _repository = repository,
       _streamer = streamer,
       _mosqueRepository = mosqueRepository,
       _authRepository = authRepository,
       super(const RecitationState()) {
    on<StartRecitationTracking>(_onStart);
    on<StopRecitationTracking>(_onStop);
    on<RecitationAiEventReceived>(_onAiEvent);
    on<RecitationPageSelected>(_onPageSelected);
    on<RecitationFailed>(_onFailed);
  }

  Future<void> _onStart(
    StartRecitationTracking event,
    Emitter<RecitationState> emit,
  ) async {
    final startPage = _findPageForAyah(event.surah, event.ayah);
    await _startRunner.run(
      checkConnectivity: false,
      onStart: () => emit(state.copyWith(isStarting: true, clearError: true)),
      onlineTask: (_) => _startTracking(event),
      onSuccess: (started) => emit(
        state.copyWith(
          isStarting: false,
          isTracking: true,
          requestId: started.authorization.requestId,
          aiSessionId: started.authorization.aiSessionId,
          highlightedVerse: TrackedVerse(
            surahNumber: event.surah,
            verseNumber: event.ayah,
            pageNumber: startPage,
            status: TrackedVerseStatus.read,
          ),
          currentPage: startPage,
          clearError: true,
        ),
      ),
      onError: (error) async {
        await _streamer.stop();
        emit(
          state.copyWith(
            isStarting: false,
            isTracking: false,
            errorMessage: _messageFor(error),
          ),
        );
      },
    );
  }

  Future<void> _onStop(
    StopRecitationTracking event,
    Emitter<RecitationState> emit,
  ) async {
    await _stopRunner.run(
      checkConnectivity: false,
      onlineTask: (_) async {
        await _publishEndedIfPossible();
        await _streamer.stop();
      },
      onSuccess: (_) => emit(
        state.copyWith(isStarting: false, isTracking: false, clearError: true),
      ),
      onError: (error) => emit(
        state.copyWith(
          isStarting: false,
          isTracking: false,
          errorMessage: _messageFor(error),
        ),
      ),
    );
  }

  Future<void> _onAiEvent(
    RecitationAiEventReceived event,
    Emitter<RecitationState> emit,
  ) async {
    final highlightedVerse = _verseFromAiEvent(event.event);
    emit(
      state.copyWith(
        lastEvent: event.event,
        clearError: true,
        highlightedVerse: highlightedVerse,
        currentPage: highlightedVerse?.pageNumber,
      ),
    );

    final requestId = state.requestId;
    final aiSessionId = state.aiSessionId;
    if (requestId == null || aiSessionId == null) return;
    unawaited(
      _publishRunner.run(
        onlineTask: (_) => _repository.publishEvent(
          requestId: requestId,
          aiSessionId: aiSessionId,
          event: event.event,
        ),
      ),
    );
  }

  void _onPageSelected(
    RecitationPageSelected event,
    Emitter<RecitationState> emit,
  ) {
    emit(state.copyWith(currentPage: event.pageNumber));
  }

  void _onFailed(RecitationFailed event, Emitter<RecitationState> emit) {
    emit(state.copyWith(errorMessage: event.message, isTracking: false));
  }

  Future<_StartedRecitation> _startTracking(
    StartRecitationTracking event,
  ) async {
    final mosque = await _mosqueRepository.getActiveMosque();
    if (mosque == null || mosque.id.isEmpty) {
      throw StateError('no_mosque');
    }

    await _authRepository.setAppModeOverride(AppMode.mobileSettings);
    final hint = PositionHint(
      surah: event.surah,
      ayah: event.ayah,
      wordIndex: event.wordIndex,
    );
    final authorization = await _repository.authorize(
      mosqueId: mosque.id,
      riwayahCode: mosque.mosque.defaultRiwayahCode,
      expectedDurationSeconds: 900,
      positionHint: hint,
    );
    await _streamer.start(
      authorization: authorization,
      positionHint: hint,
      onEvent: (aiEvent) => add(RecitationAiEventReceived(aiEvent)),
      onError: (error) => add(RecitationFailed(_messageFor(error))),
    );
    return _StartedRecitation(authorization);
  }

  TrackedVerse? _verseFromAiEvent(Map<String, dynamic> event) {
    final type = event['type']?.toString();
    if (type != 'position' && type != 'error') return null;
    final surah = _readInt(event['surah']);
    final ayah =
        _readInt(event['ayah']) ?? _readNestedInt(event['expected'], 'ayah');
    if (surah == null || ayah == null) return null;
    return TrackedVerse(
      surahNumber: surah,
      verseNumber: ayah,
      pageNumber: _findPageForAyah(surah, ayah),
      status: type == 'error'
          ? TrackedVerseStatus.incorrect
          : TrackedVerseStatus.read,
    );
  }

  int _findPageForAyah(int surah, int ayah) {
    for (var page = 1; page <= totalPagesCount; page++) {
      for (final rawEntry in getPageData(page)) {
        final entry = Map<String, dynamic>.from(rawEntry as Map);
        if (entry['surah'] != surah) continue;
        final start = entry['start'] as int;
        final end = entry['end'] as int;
        if (ayah >= start && ayah <= end) return page;
      }
    }
    return state.currentPage;
  }

  int? _readInt(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  int? _readNestedInt(Object? value, String key) {
    if (value is! Map) return null;
    return _readInt(value[key]);
  }

  String _messageFor(Object error) {
    return errorMessage(error);
  }

  Future<void> _publishEndedIfPossible() async {
    final requestId = state.requestId;
    final aiSessionId = state.aiSessionId;
    if (requestId == null || aiSessionId == null) return;
    await _repository.publishEvent(
      requestId: requestId,
      aiSessionId: aiSessionId,
      event: {
        'type': 'session_state',
        'state': 'ended',
        'ts_ms': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<void> close() async {
    _startRunner.cancel();
    _stopRunner.cancel();
    _publishRunner.cancel();
    await _streamer.dispose();
    return super.close();
  }
}

class _StartedRecitation {
  final RecitationSessionAuthorization authorization;

  const _StartedRecitation(this.authorization);
}
