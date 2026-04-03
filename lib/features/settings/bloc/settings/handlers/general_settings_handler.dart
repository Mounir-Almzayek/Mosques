import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/models/mosque_model.dart';
import '../../../models/settings_edit_request.dart';
import '../settings_event.dart';
import '../settings_state.dart';

/// Mixin handling general mosque settings and individual prayer time adjustments.
mixin GeneralSettingsHandler on Bloc<SettingsEvent, SettingsState> {
  void Function(Emitter<SettingsState> emit, SettingsEditRequest next)
  get emitDraftUpdated;
  MosqueModel? get currentMosque;

  void onMosqueNameChanged(
    SettingsMosqueNameChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(name: event.name)),
    );
  }

  void onMosqueCityChanged(
    SettingsMosqueCityChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(city: event.city)),
    );
  }

  void onPrayerCalculationMethodChanged(
    SettingsPrayerCalculationMethodChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    emitDraftUpdated(
      emit,
      state.request.copyWith(
        mosque: m.copyWith(prayerCalculationMethod: event.calculationMethod),
      ),
    );
  }

  void onMosqueLanguageChanged(
    SettingsMosqueLanguageChanged event,
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

  void onMosqueCoordinatesChanged(
    SettingsMosqueCoordinatesChanged event,
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

  // --- Per-Prayer Offsets ---

  void onPrayerOffsetFajrChanged(
    SettingsPrayerOffsetFajrChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final o = m.prayerOffsets.copyWith(fajr: event.offset);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(prayerOffsets: o)),
    );
  }

  void onPrayerOffsetSunriseChanged(
    SettingsPrayerOffsetSunriseChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final o = m.prayerOffsets.copyWith(sunrise: event.offset);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(prayerOffsets: o)),
    );
  }

  void onPrayerOffsetDhuhrChanged(
    SettingsPrayerOffsetDhuhrChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final o = m.prayerOffsets.copyWith(dhuhr: event.offset);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(prayerOffsets: o)),
    );
  }

  void onPrayerOffsetAsrChanged(
    SettingsPrayerOffsetAsrChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final o = m.prayerOffsets.copyWith(asr: event.offset);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(prayerOffsets: o)),
    );
  }

  void onPrayerOffsetMaghribChanged(
    SettingsPrayerOffsetMaghribChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final o = m.prayerOffsets.copyWith(maghrib: event.offset);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(prayerOffsets: o)),
    );
  }

  void onPrayerOffsetIshaChanged(
    SettingsPrayerOffsetIshaChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final o = m.prayerOffsets.copyWith(isha: event.offset);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(prayerOffsets: o)),
    );
  }
}
