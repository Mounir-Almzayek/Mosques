import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/mosque/mosque_model.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../core/models/settings_edit_request.dart';
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
  final IMosqueRepository _mosqueRepo;
  StreamSubscription? _sub;

  SettingsBloc({required IMosqueRepository mosqueRepository})
      : _mosqueRepo = mosqueRepository,
        super(const SettingsState()) {
    on<LoadSettings>(_onLoad);

    // General
    on<GeneralSettingChanged>(onGeneralSettingChanged);
    on<LanguageChanged>(onLanguageChanged);
    on<CoordinatesChanged>(onCoordinatesChanged);
    on<PrayerOffsetChanged>(onPrayerOffsetChanged);
    on<SaveGeneralSettingsRequested>(_onSaveGeneral);

    // Design
    on<DesignBackgroundValueChanged>(onDesignBackgroundValueChanged);
    on<DesignBackgroundTypeChanged>(onDesignBackgroundTypeChanged);
    on<DesignColorChanged>(onDesignColorChanged);
    on<DesignFontSizeChanged>(onDesignFontSizeChanged);
    on<DesignTickerSpeedChanged>(onDesignTickerSpeedChanged);
    on<DesignStripSpeedChanged>(onDesignStripSpeedChanged);
    on<DesignNumeralFormatChanged>(onDesignNumeralFormatChanged);
    on<DesignFontFamilyChanged>(onDesignFontFamilyChanged);
    on<DisplayTimingChanged>(onDisplayTimingChanged);
    on<BackgroundCustomUrlChanged>(onBackgroundCustomUrlChanged);
    on<PrayerCardScaleChanged>(onPrayerCardScaleChanged);
    on<BackgroundAlbumUrlAdded>(onBackgroundAlbumUrlAdded);
    on<BackgroundAlbumUrlRemoved>(onBackgroundAlbumUrlRemoved);
    on<BackgroundAlbumUrlsReordered>(onBackgroundAlbumUrlsReordered);
    on<SaveDesignSettingsRequested>(_onSaveDesign);

    // Album
    on<AlbumImageAdded>(onAlbumImageAdded);
    on<AlbumImageRemoved>(onAlbumImageRemoved);
    on<AlbumImagePublished>(onAlbumImagePublished);
    on<AlbumImageUnpublished>(onAlbumImageUnpublished);
    on<SaveAlbumRequested>(_onSaveAlbum);

    // Iqama
    on<IqamaOffsetChanged>(onIqamaOffsetChanged);
    on<SaveIqamaSettingsRequested>(_onSaveIqama);

    // Mosque Text Lists
    on<MosqueTextAdded>(onMosqueTextAdded);
    on<MosqueTextUpdated>(onMosqueTextUpdated);
    on<MosqueTextRemoved>(onMosqueTextRemoved);
    on<SaveMosqueTextListRequested>(_onSaveTextList);

    // Announcements
    on<AnnouncementAdded>(onAnnouncementAdded);
    on<AnnouncementUpdated>(onAnnouncementUpdated);
    on<AnnouncementRemoved>(onAnnouncementRemoved);
    on<SaveAnnouncementsRequested>(_onSaveAnnouncements);

    // Alerts
    on<AlertAdded>(onAlertAdded);
    on<AlertRemoved>(onAlertRemoved);
    on<AlertPublished>(onAlertPublished);
    on<AlertUnpublished>(onAlertUnpublished);
    on<AlertUpdated>(onAlertUpdated);
    on<AllAlertsDeleted>(onAllAlertsDeleted);
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
      _mosqueRepo.streamActiveMosque,
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
    await _save(emit, () => _mosqueRepo.updateMosque(m));
  }

  Future<void> _onSaveDesign(
    SaveDesignSettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = state.request.mosque;
    if (m == null) return;
    await _save(emit, () => _mosqueRepo.updateDesignSettings(m));
  }

  Future<void> _onSaveIqama(
    SaveIqamaSettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = state.request.mosque;
    if (m == null) return;
    await _save(emit, () => _mosqueRepo.updateIqamaSettings(m));
  }

  Future<void> _onSaveTextList(
    SaveMosqueTextListRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = state.request.mosque;
    if (m == null) return;
    await _save(
      emit,
      () => _mosqueRepo.updateMosqueTextList(m, event.kind),
    );
  }

  Future<void> _onSaveAnnouncements(
    SaveAnnouncementsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = state.request.mosque;
    if (m == null) return;
    await _save(emit, () => _mosqueRepo.updateAnnouncements(m));
  }

  Future<void> _onSaveAlerts(
    SaveAlertsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = state.request.mosque;
    if (m == null) return;
    await _save(emit, () => _mosqueRepo.updateActiveAlerts(m));
  }

  Future<void> _onSaveAlbum(
    SaveAlbumRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = state.request.mosque;
    if (m == null) return;
    await _save(emit, () => _mosqueRepo.updateMosque(m));
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
