import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/error_mapper.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'general_event.dart';
import 'general_state.dart';

export 'general_event.dart';
export 'general_state.dart';

class GeneralBloc extends Bloc<GeneralEvent, GeneralState> {
  final IMosqueRepository _repo;
  final AsyncRunner<void> _saveRunner = AsyncRunner();

  GeneralBloc({required IMosqueRepository mosqueRepository})
    : _repo = mosqueRepository,
      super(const GeneralState()) {
    on<LoadGeneral>(_onLoad);
    on<GeneralMosqueUpdated>(_onMosqueUpdated);
    on<GeneralSettingChanged>(_onGeneralSettingChanged);
    on<LanguageChanged>(_onLanguageChanged);
    on<CoordinatesChanged>(_onCoordinatesChanged);
    on<PrayerOffsetChanged>(_onPrayerOffsetChanged);
    on<SaveGeneralRequested>(_onSave);
    on<DiscardGeneralChangesRequested>(_onDiscardChanges);
  }

  StreamSubscription<dynamic>? _sub;

  Future<void> _onLoad(LoadGeneral event, Emitter<GeneralState> emit) async {
    _sub?.cancel();
    emit(state.copyWith(isLoading: true));
    _sub = _repo.streamActiveMosque.listen(
      (mosque) => add(GeneralMosqueUpdated(mosque)),
      onError: (Object error) =>
          emit(state.copyWith(isLoading: false, error: errorMessage(error))),
    );
  }

  void _onMosqueUpdated(
    GeneralMosqueUpdated event,
    Emitter<GeneralState> emit,
  ) {
    // Only accept stream updates when there are no unsaved local changes.
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

  void _onGeneralSettingChanged(
    GeneralSettingChanged event,
    Emitter<GeneralState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final updated = switch (event.field) {
      GeneralField.name => m.copyWith(
        mosque: m.mosque.copyWith(name: event.value as String),
      ),
      GeneralField.city => m.copyWith(
        mosque: m.mosque.copyWith(city: event.value as String),
      ),
      GeneralField.calculationMethod => m.copyWith(
        prayerSettings: m.prayerSettings.copyWith(
          calculationMethod: event.value as String,
        ),
      ),
    };
    emit(state.copyWith(mosque: updated, hasUnsavedChanges: true));
  }

  void _onLanguageChanged(LanguageChanged event, Emitter<GeneralState> emit) {
    final m = state.mosque;
    if (m == null) return;
    emit(
      state.copyWith(
        mosque: m.copyWith(
          mosque: m.mosque.copyWith(languageCode: event.language.code),
        ),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onCoordinatesChanged(
    CoordinatesChanged event,
    Emitter<GeneralState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    emit(
      state.copyWith(
        mosque: m.copyWith(
          mosque: m.mosque.copyWith(
            latitude: event.latitude.toString(),
            longitude: event.longitude.toString(),
          ),
        ),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onPrayerOffsetChanged(
    PrayerOffsetChanged event,
    Emitter<GeneralState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final o = switch (event.prayer) {
      PrayerOffsetField.fajr => m.prayerSettings.offsets.copyWith(
        fajr: event.offset,
      ),
      PrayerOffsetField.sunrise => m.prayerSettings.offsets.copyWith(
        sunrise: event.offset,
      ),
      PrayerOffsetField.dhuhr => m.prayerSettings.offsets.copyWith(
        dhuhr: event.offset,
      ),
      PrayerOffsetField.asr => m.prayerSettings.offsets.copyWith(
        asr: event.offset,
      ),
      PrayerOffsetField.maghrib => m.prayerSettings.offsets.copyWith(
        maghrib: event.offset,
      ),
      PrayerOffsetField.isha => m.prayerSettings.offsets.copyWith(
        isha: event.offset,
      ),
    };
    emit(
      state.copyWith(
        mosque: m.copyWith(
          prayerSettings: m.prayerSettings.copyWith(offsets: o),
        ),
        hasUnsavedChanges: true,
      ),
    );
  }

  Future<void> _onSave(
    SaveGeneralRequested event,
    Emitter<GeneralState> emit,
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
    DiscardGeneralChangesRequested event,
    Emitter<GeneralState> emit,
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
