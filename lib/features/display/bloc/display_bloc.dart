import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/announcement_model.dart';
import '../../../data/models/mosque_model.dart';
import '../../../data/repositories/mosque_local_repository.dart';
import '../../../data/repositories/mosque_repository.dart';
import '../../../data/repositories/platform_announcements_repository.dart';
import 'display_event.dart';
import 'display_state.dart';

export 'display_event.dart';
export 'display_state.dart';

/// Manages real-time mosque data and platform announcements for the display screen.
///
/// Subscribes to Firestore snapshots and performs hourly server fetches
/// to keep the display in sync even if the snapshot listener reconnects.
class DisplayBloc extends Bloc<DisplayEvent, DisplayState> {
  StreamSubscription<MosqueModel?>? _mosqueSubscription;
  StreamSubscription<List<AnnouncementModel>>? _platformSubscription;
  Timer? _hourlyServerFetchTimer;

  List<AnnouncementModel> _platformAnnouncements = [];

  DisplayBloc() : super(DisplayInitial()) {
    on<StartDisplaySubscription>(_onStartSubscription);
    on<MosqueUpdated>(_onMosqueUpdated);
    on<PlatformAnnouncementsUpdated>(_onPlatformAnnouncementsUpdated);
    on<DisplayErrorEvent>(_onDisplayError);
  }

  void _emitLoaded(Emitter<DisplayState> emit, MosqueModel mosque) {
    emit(DisplayLoaded(
      mosque,
      platformAnnouncements: _platformAnnouncements,
    ));
  }

  Future<void> _onStartSubscription(
    StartDisplaySubscription event,
    Emitter<DisplayState> emit,
  ) async {
    emit(DisplayLoading());
    _mosqueSubscription?.cancel();
    _platformSubscription?.cancel();
    _platformAnnouncements = [];

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
    // If still loading, the mosque stream will trigger DisplayLoaded later.
  }

  void _onDisplayError(DisplayErrorEvent event, Emitter<DisplayState> emit) {
    emit(DisplayError(event.message));
  }

  @override
  Future<void> close() {
    _hourlyServerFetchTimer?.cancel();
    _mosqueSubscription?.cancel();
    _platformSubscription?.cancel();
    return super.close();
  }
}
