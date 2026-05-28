import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/display_background_type.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'design_event.dart';
import 'design_state.dart';

export 'design_event.dart';
export 'design_state.dart';

class DesignBloc extends Bloc<DesignEvent, DesignState> {
  final IMosqueRepository _repo;

  DesignBloc({required IMosqueRepository mosqueRepository})
      : _repo = mosqueRepository,
        super(const DesignState()) {
    on<LoadDesign>(_onLoad);
    on<DesignMosqueUpdated>(_onMosqueUpdated);
    on<DesignBackgroundValueChanged>(_onBackgroundValueChanged);
    on<DesignBackgroundTypeChanged>(_onBackgroundTypeChanged);
    on<DesignColorChanged>(_onColorChanged);
    on<DesignFontSizeChanged>(_onFontSizeChanged);
    on<DesignTickerSpeedChanged>(_onTickerSpeedChanged);
    on<DesignStripSpeedChanged>(_onStripSpeedChanged);
    on<DesignNumeralFormatChanged>(_onNumeralFormatChanged);
    on<DesignFontFamilyChanged>(_onFontFamilyChanged);
    on<DisplayTimingChanged>(_onDisplayTimingChanged);
    on<PrayerCardScaleChanged>(_onPrayerCardScaleChanged);
    on<BackgroundAlbumUrlAdded>(_onBackgroundAlbumUrlAdded);
    on<BackgroundAlbumUrlRemoved>(_onBackgroundAlbumUrlRemoved);
    on<BackgroundAlbumUrlsReordered>(_onBackgroundAlbumUrlsReordered);
    on<BackgroundCustomUrlChanged>(_onBackgroundCustomUrlChanged);
    on<SaveDesignRequested>(_onSave);
  }

  StreamSubscription<dynamic>? _sub;

  Future<void> _onLoad(LoadDesign event, Emitter<DesignState> emit) async {
    _sub?.cancel();
    emit(state.copyWith(isLoading: true));
    _sub = _repo.streamActiveMosque.listen(
      (mosque) => add(DesignMosqueUpdated(mosque)),
      onError: (Object error) =>
          emit(state.copyWith(isLoading: false, error: error.toString())),
    );
  }

  void _onMosqueUpdated(DesignMosqueUpdated event, Emitter<DesignState> emit) {
    if (!state.hasUnsavedChanges) {
      emit(state.copyWith(
        isLoading: false,
        mosque: event.mosque,
        hasUnsavedChanges: false,
      ));
    } else {
      emit(state.copyWith(isLoading: false));
    }
  }

  // ── Background ──

  void _onBackgroundValueChanged(
    DesignBackgroundValueChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(
      background: m.designSettings.background.copyWith(
        value: event.backgroundValue,
      ),
    );
    emit(state.copyWith(
      mosque: m.copyWith(designSettings: d),
      hasUnsavedChanges: true,
    ));
  }

  void _onBackgroundTypeChanged(
    DesignBackgroundTypeChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(
      background: m.designSettings.background.copyWith(type: event.type),
    );
    emit(state.copyWith(
      mosque: m.copyWith(designSettings: d),
      hasUnsavedChanges: true,
    ));
  }

  // ── Colors ──

  void _onColorChanged(
    DesignColorChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
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
    emit(state.copyWith(
      mosque: m.copyWith(designSettings: d),
      hasUnsavedChanges: true,
    ));
  }

  // ── Font sizes ──

  void _onFontSizeChanged(
    DesignFontSizeChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
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
      DesignFontSizeField.religiousContent =>
        m.designSettings.fontSizes.copyWith(religiousContent: event.fontSize),
      DesignFontSizeField.alerts =>
        m.designSettings.fontSizes.copyWith(alerts: event.fontSize),
      DesignFontSizeField.countdown =>
        m.designSettings.fontSizes.copyWith(countdown: event.fontSize),
    };
    final d = m.designSettings.copyWith(fontSizes: fontSizes);
    emit(state.copyWith(
      mosque: m.copyWith(designSettings: d),
      hasUnsavedChanges: true,
    ));
  }

  // ── Speed / typography / timing ──

  void _onTickerSpeedChanged(
    DesignTickerSpeedChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(tickerSpeed: event.speed);
    emit(state.copyWith(
      mosque: m.copyWith(designSettings: d),
      hasUnsavedChanges: true,
    ));
  }

  void _onStripSpeedChanged(
    DesignStripSpeedChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(stripSpeed: event.speed);
    emit(state.copyWith(
      mosque: m.copyWith(designSettings: d),
      hasUnsavedChanges: true,
    ));
  }

  void _onNumeralFormatChanged(
    DesignNumeralFormatChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(numeralFormat: event.format);
    emit(state.copyWith(
      mosque: m.copyWith(designSettings: d),
      hasUnsavedChanges: true,
    ));
  }

  void _onFontFamilyChanged(
    DesignFontFamilyChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(fontFamily: event.fontFamily);
    emit(state.copyWith(
      mosque: m.copyWith(designSettings: d),
      hasUnsavedChanges: true,
    ));
  }

  void _onDisplayTimingChanged(
    DisplayTimingChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = switch (event.field) {
      DisplayTimingField.preAdhanMinutes =>
        m.designSettings.copyWith(preAdhanMinutes: event.value),
      DisplayTimingField.adhanMomentDuration =>
        m.designSettings.copyWith(adhanMomentDurationSeconds: event.value),
    };
    emit(state.copyWith(
      mosque: m.copyWith(designSettings: d),
      hasUnsavedChanges: true,
    ));
  }

  // ── Prayer card scale ──

  void _onPrayerCardScaleChanged(
    PrayerCardScaleChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(prayerCardScale: event.scale);
    emit(state.copyWith(
      mosque: m.copyWith(designSettings: d),
      hasUnsavedChanges: true,
    ));
  }

  // ── Background album URLs ──

  void _onBackgroundAlbumUrlAdded(
    BackgroundAlbumUrlAdded event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final urls = [...m.albumImageUrls, event.url];
    emit(state.copyWith(
      mosque: m.copyWith(albumImageUrls: urls),
      hasUnsavedChanges: true,
    ));
  }

  void _onBackgroundAlbumUrlRemoved(
    BackgroundAlbumUrlRemoved event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final urls = List<String>.from(m.albumImageUrls)..removeAt(event.index);
    emit(state.copyWith(
      mosque: m.copyWith(albumImageUrls: urls),
      hasUnsavedChanges: true,
    ));
  }

  void _onBackgroundAlbumUrlsReordered(
    BackgroundAlbumUrlsReordered event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    emit(state.copyWith(
      mosque: m.copyWith(albumImageUrls: event.urls),
      hasUnsavedChanges: true,
    ));
  }

  void _onBackgroundCustomUrlChanged(
    BackgroundCustomUrlChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(
      background: m.designSettings.background.copyWith(
        type: DisplayBackgroundType.album,
        value: event.url,
      ),
    );
    emit(state.copyWith(
      mosque: m.copyWith(designSettings: d),
      hasUnsavedChanges: true,
    ));
  }

  // ── Save ──

  Future<void> _onSave(
    SaveDesignRequested event,
    Emitter<DesignState> emit,
  ) async {
    final m = state.mosque;
    if (m == null) return;
    emit(state.copyWith(isSaving: true));
    try {
      await _repo.updateDesignSettings(m);
      emit(state.copyWith(
        isSaving: false,
        hasUnsavedChanges: false,
        error: null,
      ));
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
