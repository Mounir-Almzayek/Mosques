import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/mosque_model.dart';
import '../../../../data/repositories/mosque_repository.dart';
import '../../models/settings_edit_request.dart';
import 'handlers/announcement_handler.dart';
import 'handlers/design_settings_handler.dart';
import 'handlers/general_settings_handler.dart';
import 'handlers/iqama_settings_handler.dart';
import 'handlers/mosque_text_handler.dart';
import 'settings_event.dart';
import 'settings_state.dart';

export 'settings_event.dart';
export 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState>
    with
        GeneralSettingsHandler,
        DesignSettingsHandler,
        IqamaSettingsHandler,
        MosqueTextHandler,
        AnnouncementHandler {
  StreamSubscription? _sub;

  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettings>(_onLoad);

    // General
    on<SettingsMosqueNameChanged>(onMosqueNameChanged);
    on<SettingsMosqueCityChanged>(onMosqueCityChanged);
    on<SettingsPrayerCalculationMethodChanged>(
      onPrayerCalculationMethodChanged,
    );
    on<SettingsMosqueLanguageChanged>(onMosqueLanguageChanged);
    on<SettingsMosqueCoordinatesChanged>(onMosqueCoordinatesChanged);
    on<SettingsPrayerOffsetFajrChanged>(onPrayerOffsetFajrChanged);
    on<SettingsPrayerOffsetSunriseChanged>(onPrayerOffsetSunriseChanged);
    on<SettingsPrayerOffsetDhuhrChanged>(onPrayerOffsetDhuhrChanged);
    on<SettingsPrayerOffsetAsrChanged>(onPrayerOffsetAsrChanged);
    on<SettingsPrayerOffsetMaghribChanged>(onPrayerOffsetMaghribChanged);
    on<SettingsPrayerOffsetIshaChanged>(onPrayerOffsetIshaChanged);
    on<SaveGeneralSettingsRequested>(_onSaveGeneral);

    // Design
    on<SettingsDesignBackgroundValueChanged>(onDesignBackgroundValueChanged);
    on<SettingsDesignBackgroundTypeChanged>(onDesignBackgroundTypeChanged);
    on<SettingsDesignPrimaryColorChanged>(onDesignPrimaryColorChanged);
    on<SettingsDesignSecondaryColorChanged>(onDesignSecondaryColorChanged);
    on<SettingsDesignPrayerOverlayChanged>(onDesignPrayerOverlayChanged);
    on<SettingsDesignActiveCardColorChanged>(onDesignActiveCardColorChanged);
    on<SettingsDesignActiveCardTextColorChanged>(
      onDesignActiveCardTextColorChanged,
    );
    on<SettingsDesignInactiveCardTextColorChanged>(
      onDesignInactiveCardTextColorChanged,
    );
    on<SettingsDesignClockFontSizeChanged>(onDesignClockFontSizeChanged);
    on<SettingsDesignMosqueInfoFontSizeChanged>(
      onDesignMosqueInfoFontSizeChanged,
    );
    on<SettingsDesignPrayersFontSizeChanged>(onDesignPrayersFontSizeChanged);
    on<SettingsDesignAnnouncementsFontSizeChanged>(
      onDesignAnnouncementsFontSizeChanged,
    );
    on<SettingsDesignContentFontSizeChanged>(onDesignContentFontSizeChanged);
    on<SettingsDesignTickerSpeedChanged>(onDesignTickerSpeedChanged);
    on<SettingsDesignNumeralFormatChanged>(onDesignNumeralFormatChanged);
    on<SettingsDesignFontFamilyChanged>(onDesignFontFamilyChanged);
    on<SaveDesignSettingsRequested>(_onSaveDesign);

    // Iqama
    on<SettingsIqamaFajrOffsetChanged>(onIqamaFajrChanged);
    on<SettingsIqamaDhuhrOffsetChanged>(onIqamaDhuhrChanged);
    on<SettingsIqamaAsrOffsetChanged>(onIqamaAsrChanged);
    on<SettingsIqamaMaghribOffsetChanged>(onIqamaMaghribChanged);
    on<SettingsIqamaIshaOffsetChanged>(onIqamaIshaChanged);
    on<SettingsIqamaJummahOffsetChanged>(onIqamaJummahChanged);
    on<SaveIqamaSettingsRequested>(_onSaveIqama);

    // Mosque Text Lists
    on<SettingsMosqueTextAdded>(onMosqueTextAdded);
    on<SettingsMosqueTextUpdated>(onMosqueTextUpdated);
    on<SettingsMosqueTextRemoved>(onMosqueTextRemoved);
    on<SaveMosqueTextListRequested>(_onSaveTextList);

    // Announcements
    on<SettingsAnnouncementAdded>(onAnnouncementAdded);
    on<SettingsAnnouncementUpdated>(onAnnouncementUpdated);
    on<SettingsAnnouncementRemoved>(onAnnouncementRemoved);
    on<SaveAnnouncementsRequested>(_onSaveAnnouncements);

    // Alerts
    on<SettingsAlertAdded>(onAlertAdded);
    on<SettingsAlertRemoved>(onAlertRemoved);
    on<SettingsAlertsCleared>(onAlertsCleared);
    on<SaveAlertsRequested>(_onSaveAlerts);
  }

  @override
  MosqueModel? get currentMosque => state.request.mosque;

  @override
  void Function(Emitter<SettingsState> emit, SettingsEditRequest next)
  get emitDraftUpdated => (emit, next) {
    emit(state.copyWith(request: next, hasUnsavedChanges: true));
  };

  Future<void> _onLoad(LoadSettings event, Emitter<SettingsState> emit) async {
    _sub?.cancel();
    emit(state.copyWith(isLoading: true));
    await emit.forEach(
      MosqueRepository.streamActiveMosque,
      onData: (mosque) => state.copyWith(
        isLoading: false,
        request: SettingsEditRequest(mosque: mosque),
        hasUnsavedChanges: false,
      ),
      onError: (error, stackTrace) => state.copyWith(
        isLoading: false,
        error: error.toString(),
      ),
    );
  }

  // --- Persistence ---

  Future<void> _onSaveGeneral(
    SaveGeneralSettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = state.request.mosque;
    if (m == null) return;
    await _save(emit, () => MosqueRepository.updateMosque(m));
  }

  Future<void> _onSaveDesign(
    SaveDesignSettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = state.request.mosque;
    if (m == null) return;
    await _save(emit, () => MosqueRepository.updateDesignSettings(m));
  }

  Future<void> _onSaveIqama(
    SaveIqamaSettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = state.request.mosque;
    if (m == null) return;
    await _save(emit, () => MosqueRepository.updateIqamaSettings(m));
  }

  Future<void> _onSaveTextList(
    SaveMosqueTextListRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = state.request.mosque;
    if (m == null) return;
    await _save(
      emit,
      () => MosqueRepository.updateMosqueTextList(m, event.kind),
    );
  }

  Future<void> _onSaveAnnouncements(
    SaveAnnouncementsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = state.request.mosque;
    if (m == null) return;
    await _save(emit, () => MosqueRepository.updateAnnouncements(m));
  }

  Future<void> _onSaveAlerts(
    SaveAlertsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = state.request.mosque;
    if (m == null) return;
    await _save(emit, () => MosqueRepository.updateActiveAlerts(m));
  }

  Future<void> _save(
    Emitter<SettingsState> emit,
    Future<void> Function() saver,
  ) async {
    emit(state.copyWith(isSaving: true));
    try {
      await saver();
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
