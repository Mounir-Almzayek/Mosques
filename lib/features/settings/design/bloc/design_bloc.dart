import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/display_background_type.dart';
import '../../../../core/services/error_mapper.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'design_event.dart';
import 'design_state.dart';

export 'design_event.dart';
export 'design_state.dart';

class DesignBloc extends Bloc<DesignEvent, DesignState> {
  final IMosqueRepository _repo;
  final AsyncRunner<void> _saveRunner = AsyncRunner();

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
    on<DiscardDesignChangesRequested>(_onDiscardChanges);
  }

  StreamSubscription<dynamic>? _sub;

  Future<void> _onLoad(LoadDesign event, Emitter<DesignState> emit) async {
    _sub?.cancel();
    emit(state.copyWith(isLoading: true));
    _sub = _repo.streamActiveMosque.listen(
      (mosque) => add(DesignMosqueUpdated(mosque)),
      onError: (Object error) =>
          emit(state.copyWith(isLoading: false, error: errorMessage(error))),
    );
  }

  void _onMosqueUpdated(DesignMosqueUpdated event, Emitter<DesignState> emit) {
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

  // ── Background ──

  void _onBackgroundValueChanged(
    DesignBackgroundValueChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = m.displaySettings.copyWith(
      backgroundValue: event.backgroundValue,
    );
    emit(
      state.copyWith(
        mosque: m.copyWith(displaySettings: d),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onBackgroundTypeChanged(
    DesignBackgroundTypeChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = m.displaySettings.copyWith(backgroundType: event.type.code);
    emit(
      state.copyWith(
        mosque: m.copyWith(displaySettings: d),
        hasUnsavedChanges: true,
      ),
    );
  }

  // ── Colors ──

  void _onColorChanged(DesignColorChanged event, Emitter<DesignState> emit) {
    final m = state.mosque;
    if (m == null) return;
    final d = switch (event.field) {
      DesignColorField.primary => m.displaySettings.copyWith(
        primaryColor: event.color,
      ),
      DesignColorField.secondary => m.displaySettings.copyWith(
        secondaryColor: event.color,
      ),
      DesignColorField.prayerOverlay => m.displaySettings.copyWith(
        prayerOverlayColor: event.color,
      ),
      DesignColorField.activeCard => m.displaySettings.copyWith(
        activeCardColor: event.color,
      ),
      DesignColorField.activeCardText => m.displaySettings.copyWith(
        activeCardTextColor: event.color,
      ),
      DesignColorField.inactiveCardText => m.displaySettings.copyWith(
        inactiveCardTextColor: event.color,
      ),
      DesignColorField.countdownBackground => m.displaySettings.copyWith(
        countdownBackgroundColor: event.color,
      ),
      DesignColorField.countdownText => m.displaySettings.copyWith(
        countdownTextColor: event.color,
      ),
      DesignColorField.alertBackground => m.displaySettings.copyWith(
        alertBackgroundColor: event.color,
      ),
      DesignColorField.alertText => m.displaySettings.copyWith(
        alertTextColor: event.color,
      ),
    };
    emit(
      state.copyWith(
        mosque: m.copyWith(displaySettings: d),
        hasUnsavedChanges: true,
      ),
    );
  }

  // ── Font sizes ──

  void _onFontSizeChanged(
    DesignFontSizeChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = switch (event.field) {
      DesignFontSizeField.clock => m.displaySettings.copyWith(
        clockFontSize: event.fontSize,
      ),
      DesignFontSizeField.mosqueInfo => m.displaySettings.copyWith(
        mosqueInfoFontSize: event.fontSize,
      ),
      DesignFontSizeField.prayers => m.displaySettings.copyWith(
        prayersFontSize: event.fontSize,
      ),
      DesignFontSizeField.announcements => m.displaySettings.copyWith(
        announcementsFontSize: event.fontSize,
      ),
      DesignFontSizeField.religiousContent => m.displaySettings.copyWith(
        contentFontSize: event.fontSize,
      ),
    };
    emit(
      state.copyWith(
        mosque: m.copyWith(displaySettings: d),
        hasUnsavedChanges: true,
      ),
    );
  }

  // ── Speed / typography / timing ──

  void _onTickerSpeedChanged(
    DesignTickerSpeedChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = m.displaySettings.copyWith(tickerSpeed: event.speed);
    emit(
      state.copyWith(
        mosque: m.copyWith(displaySettings: d),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onStripSpeedChanged(
    DesignStripSpeedChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = m.displaySettings.copyWith(stripSpeed: event.speed);
    emit(
      state.copyWith(
        mosque: m.copyWith(displaySettings: d),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onNumeralFormatChanged(
    DesignNumeralFormatChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = m.displaySettings.copyWith(numeralFormat: event.format);
    emit(
      state.copyWith(
        mosque: m.copyWith(displaySettings: d),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onFontFamilyChanged(
    DesignFontFamilyChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = m.displaySettings.copyWith(fontFamily: event.fontFamily);
    emit(
      state.copyWith(
        mosque: m.copyWith(displaySettings: d),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onDisplayTimingChanged(
    DisplayTimingChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    // preAdhanMinutes / adhanMomentDurationSeconds moved to PrayerSettings.
    final p = switch (event.field) {
      DisplayTimingField.preAdhanMinutes => m.prayerSettings.copyWith(
        preAdhanMinutes: event.value,
      ),
      DisplayTimingField.adhanMomentDuration => m.prayerSettings.copyWith(
        adhanMomentDurationSeconds: event.value,
      ),
    };
    emit(
      state.copyWith(
        mosque: m.copyWith(prayerSettings: p),
        hasUnsavedChanges: true,
      ),
    );
  }

  // ── Prayer card scale ──

  void _onPrayerCardScaleChanged(
    PrayerCardScaleChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = m.displaySettings.copyWith(prayerCardScale: event.scale);
    emit(
      state.copyWith(
        mosque: m.copyWith(displaySettings: d),
        hasUnsavedChanges: true,
      ),
    );
  }

  // ── Background album URLs ──

  void _onBackgroundAlbumUrlAdded(
    BackgroundAlbumUrlAdded event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final urls = [...m.displaySettings.albumImageUrls, event.url];
    emit(
      state.copyWith(
        mosque: m.copyWith(
          displaySettings: m.displaySettings.copyWith(albumImageUrls: urls),
        ),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onBackgroundAlbumUrlRemoved(
    BackgroundAlbumUrlRemoved event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final urls = List<String>.from(m.displaySettings.albumImageUrls)
      ..removeAt(event.index);
    emit(
      state.copyWith(
        mosque: m.copyWith(
          displaySettings: m.displaySettings.copyWith(albumImageUrls: urls),
        ),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onBackgroundAlbumUrlsReordered(
    BackgroundAlbumUrlsReordered event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    emit(
      state.copyWith(
        mosque: m.copyWith(
          displaySettings: m.displaySettings.copyWith(
            albumImageUrls: event.urls,
          ),
        ),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onBackgroundCustomUrlChanged(
    BackgroundCustomUrlChanged event,
    Emitter<DesignState> emit,
  ) {
    final m = state.mosque;
    if (m == null) return;
    final d = m.displaySettings.copyWith(
      backgroundType: DisplayBackgroundType.album.code,
      backgroundValue: event.url,
    );
    emit(
      state.copyWith(
        mosque: m.copyWith(displaySettings: d),
        hasUnsavedChanges: true,
      ),
    );
  }

  // ── Save ──

  Future<void> _onSave(
    SaveDesignRequested event,
    Emitter<DesignState> emit,
  ) async {
    final m = state.mosque;
    if (m == null) return;
    await _saveRunner.run(
      checkConnectivity: false,
      onlineTask: (_) => _repo.updateDesignSettings(m),
      onStart: () => emit(state.copyWith(isSaving: true)),
      onSuccess: (_) => emit(
        state.copyWith(isSaving: false, hasUnsavedChanges: false, error: null),
      ),
      onError: (error) =>
          emit(state.copyWith(isSaving: false, error: errorMessage(error))),
    );
  }

  void _onDiscardChanges(
    DiscardDesignChangesRequested event,
    Emitter<DesignState> emit,
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
