import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'general_event.dart';
import 'general_state.dart';

export 'general_event.dart';
export 'general_state.dart';

class GeneralBloc extends Bloc<GeneralEvent, GeneralState> {
  final IMosqueRepository _repo;

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
  }

  StreamSubscription<dynamic>? _sub;

  Future<void> _onLoad(LoadGeneral event, Emitter<GeneralState> emit) async {
    _sub?.cancel();
    emit(state.copyWith(isLoading: true));
    _sub = _repo.streamActiveMosque.listen(
      (mosque) => add(GeneralMosqueUpdated(mosque)),
      onError: (Object error) =>
          emit(state.copyWith(isLoading: false, error: error.toString())),
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
      GeneralField.name => m.copyWith(name: event.value as String),
      GeneralField.city => m.copyWith(city: event.value as String),
      GeneralField.calculationMethod => m.copyWith(
        prayerCalculationMethod: event.value as String,
      ),
    };
    emit(state.copyWith(mosque: updated, hasUnsavedChanges: true));
  }

  void _onLanguageChanged(LanguageChanged event, Emitter<GeneralState> emit) {
    final m = state.mosque;
    if (m == null) return;
    emit(
      state.copyWith(
        mosque: m.copyWith(appLanguageCode: event.language.code),
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
          latitude: event.latitude,
          longitude: event.longitude,
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
      PrayerOffsetField.fajr => m.prayerOffsets.copyWith(fajr: event.offset),
      PrayerOffsetField.sunrise => m.prayerOffsets.copyWith(
        sunrise: event.offset,
      ),
      PrayerOffsetField.dhuhr => m.prayerOffsets.copyWith(dhuhr: event.offset),
      PrayerOffsetField.asr => m.prayerOffsets.copyWith(asr: event.offset),
      PrayerOffsetField.maghrib => m.prayerOffsets.copyWith(
        maghrib: event.offset,
      ),
      PrayerOffsetField.isha => m.prayerOffsets.copyWith(isha: event.offset),
    };
    emit(
      state.copyWith(
        mosque: m.copyWith(prayerOffsets: o),
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
    emit(state.copyWith(isSaving: true));
    try {
      await _repo.updateMosque(m);
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
