import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/mosque_model.dart';
import '../../../../data/repositories/mosque_local_repository.dart';
import '../../../../data/repositories/mosque_repository.dart';
import '../../../../data/repositories/platform_announcements_repository.dart';

abstract class DisplayEvent extends Equatable {
  const DisplayEvent();

  @override
  List<Object?> get props => [];
}

class StartDisplaySubscription extends DisplayEvent {}

class MosqueUpdated extends DisplayEvent {
  final MosqueModel? mosque;

  const MosqueUpdated(this.mosque);

  @override
  List<Object?> get props => [mosque];
}

/// بث من [platform_announcements] — تُحدَّث من خارج تطبيق الجوال فقط.
class PlatformAnnouncementsUpdated extends DisplayEvent {
  final List<AnnouncementModel> announcements;

  const PlatformAnnouncementsUpdated(this.announcements);

  @override
  List<Object?> get props => [announcements];
}

class DisplayErrorEvent extends DisplayEvent {
  final String message;

  const DisplayErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}

abstract class DisplayState extends Equatable {
  const DisplayState();

  @override
  List<Object?> get props => [];
}

class DisplayInitial extends DisplayState {}

class DisplayLoading extends DisplayState {}

class DisplayLoaded extends DisplayState {
  final MosqueModel mosque;
  final List<AnnouncementModel> platformAnnouncements;

  const DisplayLoaded(
    this.mosque, {
    this.platformAnnouncements = const [],
  });

  @override
  List<Object?> get props => [mosque, platformAnnouncements];
}

class DisplayError extends DisplayState {
  final String message;

  const DisplayError(this.message);

  @override
  List<Object?> get props => [message];
}

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

    final cached = await MosqueLocalRepository.getCachedForActiveMosque();
    if (cached != null) {
      add(MosqueUpdated(cached));
    }

    _platformSubscription =
        PlatformAnnouncementsRepository.watchActiveForDisplay().listen(
      (list) => add(PlatformAnnouncementsUpdated(list)),
      // لا نوقف شاشة العرض — الإعلانات العامة اختيارية
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

  /// مزامنة من السيرفر كل ساعة عند توفر الشبكة؛ بدون شبكة يُتخطى ويُعاد المحاولة في الساعة التالية.
  Future<void> _runHourlyServerFetch() async {
    if (isClosed) return;
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) return;

      final mosque = await MosqueRepository.fetchActiveMosqueFromServer();
      if (mosque != null && !isClosed) {
        add(MosqueUpdated(mosque));
      }
      final platform = await PlatformAnnouncementsRepository.fetchActiveForDisplayFromServer();
      if (!isClosed) {
        add(PlatformAnnouncementsUpdated(platform));
      }
    } catch (_) {
      // أخطاء الشبكة أو Firestore: ننتظر المحاولة في الساعة القادمة
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
    } else if (current is DisplayLoading) {
      // انتظر وصول بيانات المسجد
    } else {
      // إن وُجد مسجد لاحقاً عبر المجرى الآخر سيُصدر DisplayLoaded
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
    return super.close();
  }
}
