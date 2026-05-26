import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/models/mosque/mosque_model.dart';
import '../../../models/settings_edit_request.dart';
import '../settings_event.dart';
import '../settings_state.dart';

/// Mixin handling general mosque settings and individual prayer time adjustments.
mixin GeneralSettingsHandler on Bloc<SettingsEvent, SettingsState> {
  void Function(Emitter<SettingsState> emit, SettingsEditRequest next)
  get emitDraftUpdated;
  MosqueModel? get currentMosque;

  void onGeneralSettingChanged(
    GeneralSettingChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final updated = switch (event.field) {
      GeneralField.name => m.copyWith(name: event.value as String),
      GeneralField.city => m.copyWith(city: event.value as String),
      GeneralField.calculationMethod =>
        m.copyWith(prayerCalculationMethod: event.value as String),
    };
    emitDraftUpdated(emit, state.request.copyWith(mosque: updated));
  }

  void onLanguageChanged(
    LanguageChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    emitDraftUpdated(
      emit,
      state.request.copyWith(
        mosque: m.copyWith(appLanguageCode: event.language.code),
      ),
    );
  }

  void onCoordinatesChanged(
    CoordinatesChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    emitDraftUpdated(
      emit,
      state.request.copyWith(
        mosque: m.copyWith(
          latitude: event.latitude,
          longitude: event.longitude,
        ),
      ),
    );
  }

  void onPrayerOffsetChanged(
    PrayerOffsetChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final o = switch (event.prayer) {
      PrayerOffsetField.fajr => m.prayerOffsets.copyWith(fajr: event.offset),
      PrayerOffsetField.sunrise =>
        m.prayerOffsets.copyWith(sunrise: event.offset),
      PrayerOffsetField.dhuhr => m.prayerOffsets.copyWith(dhuhr: event.offset),
      PrayerOffsetField.asr => m.prayerOffsets.copyWith(asr: event.offset),
      PrayerOffsetField.maghrib =>
        m.prayerOffsets.copyWith(maghrib: event.offset),
      PrayerOffsetField.isha => m.prayerOffsets.copyWith(isha: event.offset),
    };
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(prayerOffsets: o)),
    );
  }
}
