import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/mosque_model.dart';
import '../../models/settings_edit_request.dart';
import '../settings_event.dart';
import '../settings_state.dart';

/// Mixin handling design settings (background, colors, font size, ticker speed, numeral format).
mixin DesignSettingsHandler on Bloc<SettingsEvent, SettingsState> {
  void Function(Emitter<SettingsState> emit, SettingsEditRequest next)
      get emitDraftUpdated;
  MosqueModel? get currentMosque;

  void onDesignBackgroundValueChanged(
    SettingsDesignBackgroundValueChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(backgroundValue: event.backgroundValue);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignPrimaryColorChanged(
    SettingsDesignPrimaryColorChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(primaryColor: event.primaryColor);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignSecondaryColorChanged(
    SettingsDesignSecondaryColorChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(secondaryColor: event.secondaryColor);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignPrayerOverlayChanged(
    SettingsDesignPrayerOverlayChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(
      prayerOverlayColor: event.prayerOverlayColor,
    );
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignActiveCardColorChanged(
    SettingsDesignActiveCardColorChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(activeCardColor: event.color);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignActiveCardTextColorChanged(
    SettingsDesignActiveCardTextColorChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(activeCardTextColor: event.color);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignInactiveCardTextColorChanged(
    SettingsDesignInactiveCardTextColorChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(inactiveCardTextColor: event.color);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignBaseFontSizeChanged(
    SettingsDesignBaseFontSizeChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(baseFontSize: event.baseFontSize);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignTickerSpeedChanged(
    SettingsDesignTickerSpeedChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(tickerSpeed: event.speed);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignNumeralFormatChanged(
    SettingsDesignNumeralFormatChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(numeralFormat: event.format);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignFontFamilyChanged(
    SettingsDesignFontFamilyChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(fontFamily: event.fontFamily);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }
}
