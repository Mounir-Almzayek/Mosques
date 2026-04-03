import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/announcement_model.dart';
import '../../../data/models/app_settings_model.dart';
import '../../../data/models/mosque_model.dart';
import '../../../data/repositories/app_settings_repository.dart';
import '../../../data/repositories/mosque_local_repository.dart';
import '../../../data/repositories/mosque_repository.dart';
import '../../../data/repositories/platform_announcements_repository.dart';
import '../../../core/utils/version_helper.dart';
import 'display_event.dart';
import 'display_state.dart';

export 'display_event.dart';
export 'display_state.dart';

/// Manages real-time mosque data and platform announcements for the display screen.
class DisplayBloc extends Bloc<DisplayEvent, DisplayState> {
  StreamSubscription<MosqueModel?>? _mosqueSubscription;
  StreamSubscription<List<AnnouncementModel>>? _platformSubscription;
  StreamSubscription<AppSettingsModel?>? _appSettingsSubscription;
  Timer? _hourlyServerFetchTimer;

  List<AnnouncementModel> _platformAnnouncements = [];
  AppSettingsModel? _appSettings;
  String? _currentVersion;

  DisplayBloc() : super(DisplayInitial()) {
    on<StartDisplaySubscription>(_onStartSubscription);
    on<MosqueUpdated>(_onMosqueUpdated);
    on<PlatformAnnouncementsUpdated>(_onPlatformAnnouncementsUpdated);
    on<AppSettingsUpdated>(_onAppSettingsUpdated);
    on<CurrentVersionUpdated>(_onCurrentVersionUpdated);
    on<DisplayErrorEvent>(_onDisplayError);
  }

  void _emitLoaded(Emitter<DisplayState> emit, MosqueModel mosque) {
    emit(DisplayLoaded(
      mosque,
      platformAnnouncements: _platformAnnouncements,
      appSettings: _appSettings,
      currentVersion: _currentVersion,
    ));
  }

  Future<void> _onStartSubscription(
    StartDisplaySubscription event,
    Emitter<DisplayState> emit,
  ) async {
    emit(DisplayLoading());
    _mosqueSubscription?.cancel();
    _platformSubscription?.cancel();
    _appSettingsSubscription?.cancel();
    _platformAnnouncements = [];

    // جلب رقم نسخة التطبيق الحالية
    VersionHelper.getCurrentVersion().then((v) => add(CurrentVersionUpdated(v)));

    // مراقبة الإعدادات العامة والتحديثات
    _appSettingsSubscription = AppSettingsRepository.streamAppSettings.listen(
      (s) => add(AppSettingsUpdated(s)),
    );

    // Show cached data immediately while waiting for network.
    final cached = await MosqueLocalRepository.getCachedForActiveMosque();
    if (cached != null) {
      add(MosqueUpdated(cached));
    }

    _platformSubscription =
        PlatformAnnouncementsRepository.watchActiveForDisplay().listen(
      (list) => add(PlatformAnnouncementsUpdated(list)),
      onError: (error, stackTrace) {},
    );

    _mosqueSubscription = MosqueRepository.streamActiveMosque.listen(
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
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) return;

      final mosque = await MosqueRepository.fetchActiveMosqueFromServer();
      if (mosque != null && !isClosed) {
        add(MosqueUpdated(mosque));
      }
      final platform =
          await PlatformAnnouncementsRepository.fetchActiveForDisplayFromServer();
      if (!isClosed) {
        add(PlatformAnnouncementsUpdated(platform));
      }
      final global = await AppSettingsRepository.getAppSettings();
      if (!isClosed) {
        add(AppSettingsUpdated(global));
      }
    } catch (_) {
      // Network errors: retry next hour.
    }
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

  void _onAppSettingsUpdated(AppSettingsUpdated event, Emitter<DisplayState> emit) {
    _appSettings = event.settings;
    final current = state;
    if (current is DisplayLoaded) {
      _emitLoaded(emit, current.mosque);
    }
  }

  void _onCurrentVersionUpdated(CurrentVersionUpdated event, Emitter<DisplayState> emit) {
    _currentVersion = event.version;
    final current = state;
    if (current is DisplayLoaded) {
      _emitLoaded(emit, current.mosque);
    }
  }

  void _onDisplayError(DisplayErrorEvent event, Emitter<DisplayState> emit) {
    emit(DisplayError(event.message));
  }

  @override
  Future<void> close() {
    _hourlyServerFetchTimer?.cancel();
    _mosqueSubscription?.cancel();
    _platformSubscription?.cancel();
    _appSettingsSubscription?.cancel();
    return super.close();
  }
}
