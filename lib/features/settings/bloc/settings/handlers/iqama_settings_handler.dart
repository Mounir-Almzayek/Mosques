import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/models/mosque/mosque_model.dart';
import '../../../models/settings_edit_request.dart';
import '../settings_event.dart';
import '../settings_state.dart';

/// Mixin handling iqama offset settings (fajr, dhuhr, asr, maghrib, isha, jummah).
mixin IqamaSettingsHandler on Bloc<SettingsEvent, SettingsState> {
  void Function(Emitter<SettingsState> emit, SettingsEditRequest next)
  get emitDraftUpdated;
  MosqueModel? get currentMosque;

  void onIqamaFajrChanged(
    SettingsIqamaFajrOffsetChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final i = m.iqamaSettings.copyWith(fajrOffset: event.offset);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(iqamaSettings: i)),
    );
  }

  void onIqamaDhuhrChanged(
    SettingsIqamaDhuhrOffsetChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final i = m.iqamaSettings.copyWith(dhuhrOffset: event.offset);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(iqamaSettings: i)),
    );
  }

  void onIqamaAsrChanged(
    SettingsIqamaAsrOffsetChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final i = m.iqamaSettings.copyWith(asrOffset: event.offset);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(iqamaSettings: i)),
    );
  }

  void onIqamaMaghribChanged(
    SettingsIqamaMaghribOffsetChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final i = m.iqamaSettings.copyWith(maghribOffset: event.offset);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(iqamaSettings: i)),
    );
  }

  void onIqamaIshaChanged(
    SettingsIqamaIshaOffsetChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final i = m.iqamaSettings.copyWith(ishaOffset: event.offset);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(iqamaSettings: i)),
    );
  }

  void onIqamaJummahChanged(
    SettingsIqamaJummahOffsetChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final i = m.iqamaSettings.copyWith(jummahOffset: event.offset);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(iqamaSettings: i)),
    );
  }
}

