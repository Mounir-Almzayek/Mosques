import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/models/mosque_model.dart';
import '../../../models/settings_edit_request.dart';
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
    final d = m.designSettings.copyWith(
      background: m.designSettings.background.copyWith(
        value: event.backgroundValue,
      ),
    );
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignBackgroundTypeChanged(
    SettingsDesignBackgroundTypeChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(
      background: m.designSettings.background.copyWith(type: event.type),
    );
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
    final d = m.designSettings.copyWith(
      colors: m.designSettings.colors.copyWith(primary: event.primaryColor),
    );
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
    final d = m.designSettings.copyWith(
      colors: m.designSettings.colors.copyWith(secondary: event.secondaryColor),
    );
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
      colors: m.designSettings.colors.copyWith(
        prayerOverlay: event.prayerOverlayColor,
      ),
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
    final d = m.designSettings.copyWith(
      colors: m.designSettings.colors.copyWith(activeCard: event.color),
    );
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
    final d = m.designSettings.copyWith(
      colors: m.designSettings.colors.copyWith(activeCardText: event.color),
    );
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
    final d = m.designSettings.copyWith(
      colors: m.designSettings.colors.copyWith(inactiveCardText: event.color),
    );
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignClockFontSizeChanged(
    SettingsDesignClockFontSizeChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(
      fontSizes: m.designSettings.fontSizes.copyWith(clock: event.fontSize),
    );
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignMosqueInfoFontSizeChanged(
    SettingsDesignMosqueInfoFontSizeChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(
      fontSizes: m.designSettings.fontSizes.copyWith(
        mosqueInfo: event.fontSize,
      ),
    );
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignPrayersFontSizeChanged(
    SettingsDesignPrayersFontSizeChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(
      fontSizes: m.designSettings.fontSizes.copyWith(prayers: event.fontSize),
    );
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignAnnouncementsFontSizeChanged(
    SettingsDesignAnnouncementsFontSizeChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(
      fontSizes: m.designSettings.fontSizes.copyWith(
        announcements: event.fontSize,
      ),
    );
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignContentFontSizeChanged(
    SettingsDesignContentFontSizeChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(
      fontSizes: m.designSettings.fontSizes.copyWith(content: event.fontSize),
    );
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
