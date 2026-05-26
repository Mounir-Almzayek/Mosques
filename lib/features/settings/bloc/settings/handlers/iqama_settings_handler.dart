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

  void onIqamaOffsetChanged(
    IqamaOffsetChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final i = switch (event.prayer) {
      IqamaField.fajr => m.iqamaSettings.copyWith(fajrOffset: event.offset),
      IqamaField.dhuhr => m.iqamaSettings.copyWith(dhuhrOffset: event.offset),
      IqamaField.asr => m.iqamaSettings.copyWith(asrOffset: event.offset),
      IqamaField.maghrib =>
        m.iqamaSettings.copyWith(maghribOffset: event.offset),
      IqamaField.isha => m.iqamaSettings.copyWith(ishaOffset: event.offset),
      IqamaField.jummah =>
        m.iqamaSettings.copyWith(jummahOffset: event.offset),
    };
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(iqamaSettings: i)),
    );
  }
}
