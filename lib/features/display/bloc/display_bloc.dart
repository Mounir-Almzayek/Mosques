import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';

import '../../../core/utils/async_runner.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/realtime/snapshot_sync.dart';
import '../../../core/widgets/quran/tracked_verse.dart';
import '../../../data/models/app/app_config.dart';
import '../../../data/models/mosque/mosque_bootstrap.dart';
import '../../../data/repositories/interfaces/app_config_repository_interface.dart';
import '../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../../data/repositories/interfaces/platform_announcements_repository_interface.dart';
import '../../../core/utils/version_helper.dart';
import 'display_event.dart';
import 'display_state.dart';

export 'display_event.dart';
export 'display_state.dart';

/// Manages real-time mosque data and platform announcements for the display screen.
class DisplayBloc extends Bloc<DisplayEvent, DisplayState> {
  final IMosqueRepository _mosqueRepo;
  final IPlatformAnnouncementsRepository _platformRepo;
  final IAppConfigRepository _appSettingsRepo;

  StreamSubscription<MosqueBootstrap?>? _mosqueSubscription;
  StreamSubscription<List<Announcement>>? _platformSubscription;
  StreamSubscription<AppConfig?>? _appSettingsSubscription;
  StreamSubscription<Map<String, dynamic>>? _recitationSubscription;
  Timer? _hourlyServerFetchTimer;
  final AsyncRunner<void> _hourlyRunner = AsyncRunner();

  List<Announcement> _platformAnnouncements = [];
  AppConfig? _appSettings;
  String? _currentVersion;
  DisplayRecitationState? _recitation;

  DisplayBloc({
    required IMosqueRepository mosqueRepository,
    required IPlatformAnnouncementsRepository platformAnnouncementsRepository,
    required IAppConfigRepository appSettingsRepository,
  }) : _mosqueRepo = mosqueRepository,
       _platformRepo = platformAnnouncementsRepository,
       _appSettingsRepo = appSettingsRepository,
       super(DisplayInitial()) {
    on<StartDisplaySubscription>(_onStartSubscription);
    on<MosqueUpdated>(_onMosqueUpdated);
    on<PlatformAnnouncementsUpdated>(_onPlatformAnnouncementsUpdated);
    on<AppSettingsUpdated>(_onAppSettingsUpdated);
    on<CurrentVersionUpdated>(_onCurrentVersionUpdated);
    on<RecitationDisplayEventUpdated>(_onRecitationDisplayEventUpdated);
    on<DisplayErrorEvent>(_onDisplayError);
  }

  void _emitLoaded(Emitter<DisplayState> emit, MosqueBootstrap mosque) {
    emit(
      DisplayLoaded(
        mosque,
        platformAnnouncements: _platformAnnouncements,
        appSettings: _appSettings,
        currentVersion: _currentVersion,
        recitation: _recitation,
      ),
    );
  }

  Future<void> _onStartSubscription(
    StartDisplaySubscription event,
    Emitter<DisplayState> emit,
  ) async {
    emit(DisplayLoading());
    _mosqueSubscription?.cancel();
    _platformSubscription?.cancel();
    _appSettingsSubscription?.cancel();
    _recitationSubscription?.cancel();
    _platformAnnouncements = [];

    // جلب رقم نسخة التطبيق الحالية
    VersionHelper.getCurrentVersion().then(
      (v) => add(CurrentVersionUpdated(v)),
    );

    // مراقبة الإعدادات العامة والتحديثات
    _appSettingsSubscription = _appSettingsRepo.streamAppConfig.listen(
      (s) => add(AppSettingsUpdated(s)),
    );
    _recitationSubscription = sl<SnapshotSync>().recitationEvents.listen(
      (event) => add(RecitationDisplayEventUpdated(event)),
    );

    // Show cached data immediately while waiting for network.
    final cached = await _mosqueRepo.getActiveMosque();
    if (cached != null) {
      add(MosqueUpdated(cached));
    }

    _platformSubscription = _platformRepo.watchActiveForDisplay().listen(
      (list) => add(PlatformAnnouncementsUpdated(list)),
      onError: (error, stackTrace) {},
    );

    _mosqueSubscription = _mosqueRepo.streamActiveMosque.listen(
      (mosque) {
        if (mosque != null) {
          add(MosqueUpdated(mosque));
        } else {
          add(const DisplayErrorEvent('no_mosque'));
        }
      },
      onError: (error) {
        add(DisplayErrorEvent('Failed to stream data: $error'));
      },
    );

    _hourlyServerFetchTimer?.cancel();
    _hourlyServerFetchTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => unawaited(_runHourlyServerFetch()),
    );
  }

  /// Syncs from the server every hour when the network is available.
  Future<void> _runHourlyServerFetch() async {
    if (isClosed) return;
    await _hourlyRunner.run(
      // Skip the fetch entirely when offline; retry next hour.
      offlineTask: (_) async {},
      onlineTask: (_) async {
        final mosque = await _mosqueRepo.fetchActiveMosqueFromServer();
        if (mosque != null && !isClosed) {
          add(MosqueUpdated(mosque));
        }
        final platform = await _platformRepo.fetchActiveForDisplayFromServer();
        if (!isClosed) {
          add(PlatformAnnouncementsUpdated(platform));
        }
        final global = await _appSettingsRepo.getAppConfig();
        if (!isClosed) {
          add(AppSettingsUpdated(global));
        }
      },
      // Network errors: retry next hour.
      onError: (_) {},
    );
  }

  void _onMosqueUpdated(MosqueUpdated event, Emitter<DisplayState> emit) {
    if (event.mosque != null) {
      _emitLoaded(emit, event.mosque!);
    }
  }

  void _onPlatformAnnouncementsUpdated(
    PlatformAnnouncementsUpdated event,
    Emitter<DisplayState> emit,
  ) {
    _platformAnnouncements = event.announcements;
    final current = state;
    if (current is DisplayLoaded) {
      _emitLoaded(emit, current.mosque);
    }
  }

  void _onAppSettingsUpdated(
    AppSettingsUpdated event,
    Emitter<DisplayState> emit,
  ) {
    _appSettings = event.settings;
    final current = state;
    if (current is DisplayLoaded) {
      _emitLoaded(emit, current.mosque);
    }
  }

  void _onCurrentVersionUpdated(
    CurrentVersionUpdated event,
    Emitter<DisplayState> emit,
  ) {
    _currentVersion = event.version;
    final current = state;
    if (current is DisplayLoaded) {
      _emitLoaded(emit, current.mosque);
    }
  }

  void _onRecitationDisplayEventUpdated(
    RecitationDisplayEventUpdated event,
    Emitter<DisplayState> emit,
  ) {
    _recitation = _recitationFromFrame(event.event);
    final current = state;
    if (current is DisplayLoaded) {
      _emitLoaded(emit, current.mosque);
    }
  }

  DisplayRecitationState? _recitationFromFrame(Map<String, dynamic>? frame) {
    if (frame == null) return null;
    final raw = frame['event'];
    final event = raw is Map
        ? Map<String, dynamic>.from(raw)
        : Map<String, dynamic>.from(frame);
    final type = event['type']?.toString();
    if (type == 'session_state' && event['state']?.toString() == 'ended') {
      return null;
    }
    final highlightedVerse = _verseFromAiEvent(event);
    return DisplayRecitationState(
      currentPage:
          highlightedVerse?.pageNumber ?? _recitation?.currentPage ?? 1,
      highlightedVerse: highlightedVerse ?? _recitation?.highlightedVerse,
      event: event,
    );
  }

  TrackedVerse? _verseFromAiEvent(Map<String, dynamic> event) {
    final type = event['type']?.toString();
    if (type != 'position' && type != 'error') return null;
    final surah = _readInt(event['surah']);
    final ayah =
        _readInt(event['ayah']) ?? _readNestedInt(event['expected'], 'ayah');
    if (surah == null || ayah == null) return null;
    return TrackedVerse(
      surahNumber: surah,
      verseNumber: ayah,
      pageNumber: _findPageForAyah(surah, ayah),
      status: type == 'error'
          ? TrackedVerseStatus.incorrect
          : TrackedVerseStatus.read,
    );
  }

  int _findPageForAyah(int surah, int ayah) {
    for (var page = 1; page <= totalPagesCount; page++) {
      for (final rawEntry in getPageData(page)) {
        final entry = Map<String, dynamic>.from(rawEntry as Map);
        if (entry['surah'] != surah) continue;
        final start = entry['start'] as int;
        final end = entry['end'] as int;
        if (ayah >= start && ayah <= end) return page;
      }
    }
    return _recitation?.currentPage ?? 1;
  }

  int? _readInt(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  int? _readNestedInt(Object? value, String key) {
    if (value is! Map) return null;
    return _readInt(value[key]);
  }

  void _onDisplayError(DisplayErrorEvent event, Emitter<DisplayState> emit) {
    emit(DisplayError(event.message));
  }

  @override
  Future<void> close() {
    _hourlyServerFetchTimer?.cancel();
    _hourlyRunner.cancel();
    _mosqueSubscription?.cancel();
    _platformSubscription?.cancel();
    _appSettingsSubscription?.cancel();
    _recitationSubscription?.cancel();
    return super.close();
  }
}
