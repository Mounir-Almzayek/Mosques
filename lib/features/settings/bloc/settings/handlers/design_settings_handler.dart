import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/enums/display_background_type.dart';
import '../../../../../data/models/mosque/mosque_model.dart';
import '../../../models/settings_edit_request.dart';
import '../settings_event.dart';
import '../settings_state.dart';

/// Mixin handling design settings (background, colors, font size, ticker speed, numeral format).
mixin DesignSettingsHandler on Bloc<SettingsEvent, SettingsState> {
  void Function(Emitter<SettingsState> emit, SettingsEditRequest next)
  get emitDraftUpdated;
  MosqueModel? get currentMosque;

  void onDesignBackgroundValueChanged(
    DesignBackgroundValueChanged event,
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
    DesignBackgroundTypeChanged event,
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

  void onDesignColorChanged(
    DesignColorChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final colors = switch (event.field) {
      DesignColorField.primary =>
        m.designSettings.colors.copyWith(primary: event.color),
      DesignColorField.secondary =>
        m.designSettings.colors.copyWith(secondary: event.color),
      DesignColorField.prayerOverlay =>
        m.designSettings.colors.copyWith(prayerOverlay: event.color),
      DesignColorField.activeCard =>
        m.designSettings.colors.copyWith(activeCard: event.color),
      DesignColorField.activeCardText =>
        m.designSettings.colors.copyWith(activeCardText: event.color),
      DesignColorField.inactiveCardText =>
        m.designSettings.colors.copyWith(inactiveCardText: event.color),
    };
    final d = m.designSettings.copyWith(colors: colors);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignFontSizeChanged(
    DesignFontSizeChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final fontSizes = switch (event.field) {
      DesignFontSizeField.clock =>
        m.designSettings.fontSizes.copyWith(clock: event.fontSize),
      DesignFontSizeField.mosqueInfo =>
        m.designSettings.fontSizes.copyWith(mosqueInfo: event.fontSize),
      DesignFontSizeField.prayers =>
        m.designSettings.fontSizes.copyWith(prayers: event.fontSize),
      DesignFontSizeField.announcements =>
        m.designSettings.fontSizes.copyWith(announcements: event.fontSize),
      DesignFontSizeField.content =>
        m.designSettings.fontSizes.copyWith(religiousContent: event.fontSize),
    };
    final d = m.designSettings.copyWith(fontSizes: fontSizes);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignTickerSpeedChanged(
    DesignTickerSpeedChanged event,
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

  void onDesignStripSpeedChanged(
    DesignStripSpeedChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(stripSpeed: event.speed);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onDesignNumeralFormatChanged(
    DesignNumeralFormatChanged event,
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
    DesignFontFamilyChanged event,
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

  void onDisplayTimingChanged(
    DisplayTimingChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = switch (event.field) {
      DisplayTimingField.preAdhanMinutes =>
        m.designSettings.copyWith(preAdhanMinutes: event.value),
      DisplayTimingField.adhanMomentDuration =>
        m.designSettings.copyWith(adhanMomentDurationSeconds: event.value),
      DisplayTimingField.religiousContentWait =>
        m.designSettings.copyWith(religiousContentWaitSeconds: event.value),
      DisplayTimingField.religiousContentDisplay =>
        m.designSettings.copyWith(religiousContentDisplaySeconds: event.value),
    };
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onPhotoStudioUrlAdded(
    PhotoStudioUrlAdded event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final urls = [...m.photoStudioUrls, event.url];
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(photoStudioUrls: urls)),
    );
  }

  void onPhotoStudioUrlRemoved(
    PhotoStudioUrlRemoved event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final urls = m.photoStudioUrls.where((u) => u != event.url).toList();
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(photoStudioUrls: urls)),
    );
  }

  void onPrayerCardScaleChanged(
    PrayerCardScaleChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(prayerCardScale: event.scale);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void onBackgroundAlbumUrlAdded(
    BackgroundAlbumUrlAdded event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final urls = [...m.backgroundAlbumUrls, event.url];
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(backgroundAlbumUrls: urls)),
    );
  }

  void onBackgroundAlbumUrlRemoved(
    BackgroundAlbumUrlRemoved event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final urls = List<String>.from(m.backgroundAlbumUrls)..removeAt(event.index);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(backgroundAlbumUrls: urls)),
    );
  }

  void onBackgroundAlbumUrlsReordered(
    BackgroundAlbumUrlsReordered event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(backgroundAlbumUrls: event.urls)),
    );
  }

  void onBackgroundCustomUrlChanged(
    BackgroundCustomUrlChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(
      background: m.designSettings.background.copyWith(
        type: DisplayBackgroundType.album,
        value: event.url,
      ),
    );
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }
}
