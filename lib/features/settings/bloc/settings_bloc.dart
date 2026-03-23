import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_runner.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../data/models/mosque_model.dart';
import '../../../../data/repositories/mosque_local_repository.dart';
import '../../../../data/repositories/mosque_repository.dart';
import '../models/settings_edit_request.dart';
import 'settings_event.dart';
import 'settings_state.dart';

export 'settings_event.dart';
export 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc()
    : super(SettingsInitial(request: const SettingsEditRequest(mosque: null))) {
    on<LoadSettings>(_onLoadSettings);

    on<SettingsMosqueNameChanged>(_onMosqueNameChanged);
    on<SettingsMosqueCityChanged>(_onMosqueCityChanged);
    on<SettingsPrayerCalculationMethodChanged>(
      _onPrayerCalculationMethodChanged,
    );
    on<SettingsMosqueLanguageChanged>(_onMosqueLanguageChanged);
    on<SettingsMosqueCoordinatesChanged>(_onMosqueCoordinatesChanged);
    on<SaveGeneralSettingsRequested>(_onSaveGeneral);

    on<SettingsDesignBackgroundValueChanged>(_onDesignBackgroundValueChanged);
    on<SettingsDesignPrimaryColorChanged>(_onDesignPrimaryColorChanged);
    on<SettingsDesignSecondaryColorChanged>(_onDesignSecondaryColorChanged);
    on<SettingsDesignPrayerOverlayChanged>(_onDesignPrayerOverlayChanged);
    on<SettingsDesignBaseFontSizeChanged>(_onDesignBaseFontSizeChanged);
    on<SaveDesignSettingsRequested>(_onSaveDesign);

    on<SettingsIqamaFajrOffsetChanged>(_onIqamaFajrChanged);
    on<SettingsIqamaDhuhrOffsetChanged>(_onIqamaDhuhrChanged);
    on<SettingsIqamaAsrOffsetChanged>(_onIqamaAsrChanged);
    on<SettingsIqamaMaghribOffsetChanged>(_onIqamaMaghribChanged);
    on<SettingsIqamaIshaOffsetChanged>(_onIqamaIshaChanged);
    on<SettingsIqamaJummahOffsetChanged>(_onIqamaJummahChanged);
    on<SaveIqamaSettingsRequested>(_onSaveIqama);

    on<SettingsMosqueTextAdded>(_onMosqueTextAdded);
    on<SettingsMosqueTextUpdated>(_onMosqueTextUpdated);
    on<SettingsMosqueTextRemoved>(_onMosqueTextRemoved);
    on<SaveMosqueTextListRequested>(_onSaveMosqueTextList);

    on<SettingsAnnouncementAdded>(_onAnnouncementAdded);
    on<SettingsAnnouncementUpdated>(_onAnnouncementUpdated);
    on<SettingsAnnouncementRemoved>(_onAnnouncementRemoved);
    on<SaveAnnouncementsRequested>(_onSaveAnnouncements);
  }

  final AsyncRunner<MosqueModel> _loadRunner = AsyncRunner();
  final AsyncRunner<MosqueModel> _saveRunner = AsyncRunner();

  void _emitDraftUpdated(
    Emitter<SettingsState> emit,
    SettingsEditRequest next,
  ) {
    if (state is SettingsLoading) {
      emit(SettingsLoading(request: next));
    } else if (state is SettingsSaving) {
      emit(SettingsSaving(request: next));
    } else if (state is SettingsError) {
      emit(SettingsLoaded(request: next));
    } else if (state is SettingsInitial) {
      emit(SettingsLoaded(request: next));
    } else {
      emit(SettingsLoaded(request: next));
    }
  }

  MosqueModel? get _mosque => state.request.mosque;

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final prev = state.request;
    await _loadRunner.run(
      onlineTask: (_) async {
        final mosque = await MosqueRepository.getActiveMosque();
        if (mosque == null) {
          throw Exception('No active mosque linked to this account.');
        }
        return mosque;
      },
      offlineTask: (_) async {
        final mosque = await MosqueLocalRepository.getCachedForActiveMosque();
        if (mosque == null) {
          throw Exception('No active mosque linked to this account.');
        }
        return mosque;
      },
      onStart: () => emit(SettingsLoading(request: prev)),
      onSuccess: (mosque) {
        emit(SettingsLoaded(request: SettingsEditRequest(mosque: mosque)));
      },
      onOffline: (mosque) {
        emit(SettingsLoaded(request: SettingsEditRequest(mosque: mosque)));
      },
      onError: (e) {
        emit(
          SettingsError(request: prev, message: ErrorHelper.getErrorMessage(e)),
        );
      },
    );
  }

  void _onMosqueNameChanged(
    SettingsMosqueNameChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(name: event.name)),
    );
  }

  void _onMosqueCityChanged(
    SettingsMosqueCityChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(city: event.city)),
    );
  }

  void _onPrayerCalculationMethodChanged(
    SettingsPrayerCalculationMethodChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    _emitDraftUpdated(
      emit,
      state.request.copyWith(
        mosque: m.copyWith(prayerCalculationMethod: event.calculationMethod),
      ),
    );
  }

  void _onMosqueLanguageChanged(
    SettingsMosqueLanguageChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    _emitDraftUpdated(
      emit,
      state.request.copyWith(
        mosque: m.copyWith(appLanguageCode: event.language.code),
      ),
    );
  }

  void _onMosqueCoordinatesChanged(
    SettingsMosqueCoordinatesChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    _emitDraftUpdated(
      emit,
      state.request.copyWith(
        mosque: m.copyWith(
          latitude: event.latitude,
          longitude: event.longitude,
        ),
      ),
    );
  }

  Future<void> _onSaveGeneral(
    SaveGeneralSettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = _mosque;
    if (m == null || state is SettingsSaving) return;
    final req = state.request;

    await _saveRunner.run(
      onlineTask: (_) async {
        await MosqueRepository.updateMosque(m);
        return m;
      },
      onStart: () => emit(SettingsSaving(request: req)),
      onSuccess: (saved) {
        emit(SettingsLoaded(request: SettingsEditRequest(mosque: saved)));
      },
      onError: (e) {
        emit(
          SettingsError(request: req, message: ErrorHelper.getErrorMessage(e)),
        );
      },
    );
  }

  void _onDesignBackgroundValueChanged(
    SettingsDesignBackgroundValueChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(backgroundValue: event.backgroundValue);
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void _onDesignPrimaryColorChanged(
    SettingsDesignPrimaryColorChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(primaryColor: event.primaryColor);
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void _onDesignSecondaryColorChanged(
    SettingsDesignSecondaryColorChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(secondaryColor: event.secondaryColor);
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void _onDesignPrayerOverlayChanged(
    SettingsDesignPrayerOverlayChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(
      prayerOverlayColor: event.prayerOverlayColor,
    );
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  void _onDesignBaseFontSizeChanged(
    SettingsDesignBaseFontSizeChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final d = m.designSettings.copyWith(baseFontSize: event.baseFontSize);
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(designSettings: d)),
    );
  }

  Future<void> _onSaveDesign(
    SaveDesignSettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = _mosque;
    if (m == null || state is SettingsSaving) return;
    final req = state.request;

    await _saveRunner.run(
      onlineTask: (_) async {
        await MosqueRepository.updateDesignSettings(m);
        return m;
      },
      onStart: () => emit(SettingsSaving(request: req)),
      onSuccess: (saved) {
        emit(SettingsLoaded(request: SettingsEditRequest(mosque: saved)));
      },
      onError: (e) {
        emit(
          SettingsError(request: req, message: ErrorHelper.getErrorMessage(e)),
        );
      },
    );
  }

  void _onIqamaFajrChanged(
    SettingsIqamaFajrOffsetChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final i = m.iqamaSettings.copyWith(fajrOffset: event.offset);
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(iqamaSettings: i)),
    );
  }

  void _onIqamaDhuhrChanged(
    SettingsIqamaDhuhrOffsetChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final i = m.iqamaSettings.copyWith(dhuhrOffset: event.offset);
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(iqamaSettings: i)),
    );
  }

  void _onIqamaAsrChanged(
    SettingsIqamaAsrOffsetChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final i = m.iqamaSettings.copyWith(asrOffset: event.offset);
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(iqamaSettings: i)),
    );
  }

  void _onIqamaMaghribChanged(
    SettingsIqamaMaghribOffsetChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final i = m.iqamaSettings.copyWith(maghribOffset: event.offset);
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(iqamaSettings: i)),
    );
  }

  void _onIqamaIshaChanged(
    SettingsIqamaIshaOffsetChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final i = m.iqamaSettings.copyWith(ishaOffset: event.offset);
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(iqamaSettings: i)),
    );
  }

  void _onIqamaJummahChanged(
    SettingsIqamaJummahOffsetChanged event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final i = m.iqamaSettings.copyWith(jummahOffset: event.offset);
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(iqamaSettings: i)),
    );
  }

  Future<void> _onSaveIqama(
    SaveIqamaSettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = _mosque;
    if (m == null || state is SettingsSaving) return;
    final req = state.request;

    await _saveRunner.run(
      onlineTask: (_) async {
        await MosqueRepository.updateIqamaSettings(m);
        return m;
      },
      onStart: () => emit(SettingsSaving(request: req)),
      onSuccess: (saved) {
        emit(SettingsLoaded(request: SettingsEditRequest(mosque: saved)));
      },
      onError: (e) {
        emit(
          SettingsError(request: req, message: ErrorHelper.getErrorMessage(e)),
        );
      },
    );
  }

  MosqueModel _mosqueWithTextList(
    MosqueModel m,
    MosqueTextListKind kind,
    List<MosqueTextEntryModel> list,
  ) {
    switch (kind) {
      case MosqueTextListKind.hadith:
        return m.copyWith(hadiths: list);
      case MosqueTextListKind.verse:
        return m.copyWith(verses: list);
      case MosqueTextListKind.dua:
        return m.copyWith(duas: list);
      case MosqueTextListKind.adhkar:
        return m.copyWith(adhkar: list);
    }
  }

  void _onMosqueTextAdded(
    SettingsMosqueTextAdded event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final list = List<MosqueTextEntryModel>.from(m.listByKind(event.kind))
      ..add(event.item);
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: _mosqueWithTextList(m, event.kind, list)),
    );
  }

  void _onMosqueTextUpdated(
    SettingsMosqueTextUpdated event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final list = m
        .listByKind(event.kind)
        .map((h) => h.id == event.item.id ? event.item : h)
        .toList();
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: _mosqueWithTextList(m, event.kind, list)),
    );
  }

  void _onMosqueTextRemoved(
    SettingsMosqueTextRemoved event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final list = m
        .listByKind(event.kind)
        .where((h) => h.id != event.itemId)
        .toList();
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: _mosqueWithTextList(m, event.kind, list)),
    );
  }

  Future<void> _onSaveMosqueTextList(
    SaveMosqueTextListRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = _mosque;
    if (m == null || state is SettingsSaving) return;
    final req = state.request;

    await _saveRunner.run(
      onlineTask: (_) async {
        await MosqueRepository.updateMosqueTextList(m, event.kind);
        return m;
      },
      onStart: () => emit(SettingsSaving(request: req)),
      onSuccess: (saved) {
        emit(SettingsLoaded(request: SettingsEditRequest(mosque: saved)));
      },
      onError: (e) {
        emit(
          SettingsError(request: req, message: ErrorHelper.getErrorMessage(e)),
        );
      },
    );
  }

  void _onAnnouncementAdded(
    SettingsAnnouncementAdded event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final list = List<AnnouncementModel>.from(m.announcements)
      ..add(event.announcement);
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(announcements: list)),
    );
  }

  void _onAnnouncementUpdated(
    SettingsAnnouncementUpdated event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final list = m.announcements
        .map((a) => a.id == event.announcement.id ? event.announcement : a)
        .toList();
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(announcements: list)),
    );
  }

  void _onAnnouncementRemoved(
    SettingsAnnouncementRemoved event,
    Emitter<SettingsState> emit,
  ) {
    final m = _mosque;
    if (m == null) return;
    final list = m.announcements
        .where((a) => a.id != event.announcementId)
        .toList();
    _emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(announcements: list)),
    );
  }

  Future<void> _onSaveAnnouncements(
    SaveAnnouncementsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final m = _mosque;
    if (m == null || state is SettingsSaving) return;
    final req = state.request;

    await _saveRunner.run(
      onlineTask: (_) async {
        await MosqueRepository.updateAnnouncements(m);
        return m;
      },
      onStart: () => emit(SettingsSaving(request: req)),
      onSuccess: (saved) {
        emit(SettingsLoaded(request: SettingsEditRequest(mosque: saved)));
      },
      onError: (e) {
        emit(
          SettingsError(request: req, message: ErrorHelper.getErrorMessage(e)),
        );
      },
    );
  }
}
