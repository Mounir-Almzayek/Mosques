import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/error_mapper.dart';
import '../../../../core/utils/async_runner.dart';
import '../../../../data/models/mosque/mosque_bootstrap.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'alerts_event.dart';
import 'alerts_state.dart';

export 'alerts_event.dart';
export 'alerts_state.dart';

class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  final IMosqueRepository _repo;
  final AsyncRunner<void> _saveRunner = AsyncRunner();

  AlertsBloc({required IMosqueRepository mosqueRepository})
    : _repo = mosqueRepository,
      super(const AlertsState()) {
    on<LoadAlerts>(_onLoad);
    on<AlertsMosqueUpdated>(_onMosqueUpdated);
    on<AlertAdded>(_onAlertAdded);
    on<AlertRemoved>(_onAlertRemoved);
    on<AlertPublished>(_onAlertPublished);
    on<AlertUnpublished>(_onAlertUnpublished);
    on<AlertUpdated>(_onAlertUpdated);
    on<AllAlertsDeleted>(_onAllAlertsDeleted);
    on<SaveAlertsRequested>(_onSave);
  }

  StreamSubscription<dynamic>? _sub;

  /// Rebuilds a [MosqueBootstrap] whose announcement list combines the
  /// existing non-alert announcements with [alerts], normalising each alert's
  /// `announcementType` to `'alert'` so the [MosqueBootstrap.savedAlerts]
  /// getter keeps recognising them.
  MosqueBootstrap _withAlerts(MosqueBootstrap m, List<Announcement> alerts) {
    final normalised = alerts
        .map((a) => a.copyWith(announcementType: 'alert'))
        .toList();
    return m.copyWith(announcements: [...m.ads, ...normalised]);
  }

  Future<void> _onLoad(LoadAlerts event, Emitter<AlertsState> emit) async {
    _sub?.cancel();
    emit(state.copyWith(isLoading: true));
    _sub = _repo.streamActiveMosque.listen(
      (mosque) => add(AlertsMosqueUpdated(mosque)),
      onError: (Object error) =>
          emit(state.copyWith(isLoading: false, error: errorMessage(error))),
    );
  }

  void _onMosqueUpdated(AlertsMosqueUpdated event, Emitter<AlertsState> emit) {
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

  void _onAlertAdded(AlertAdded event, Emitter<AlertsState> emit) {
    final m = state.mosque;
    if (m == null) return;
    final list = List<Announcement>.from(m.savedAlerts)..add(event.alert);
    emit(
      state.copyWith(
        mosque: _withAlerts(m, list),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onAlertRemoved(AlertRemoved event, Emitter<AlertsState> emit) {
    final m = state.mosque;
    if (m == null) return;
    final list = m.savedAlerts.where((a) => a.id != event.alertId).toList();
    emit(
      state.copyWith(
        mosque: _withAlerts(m, list),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onAlertPublished(AlertPublished event, Emitter<AlertsState> emit) {
    final m = state.mosque;
    if (m == null) return;
    final now = DateTime.now();
    final list = m.savedAlerts.map((a) {
      if (a.id == event.alertId) {
        // Publishing now means: make the alert active for the chosen window.
        return a.copyWith(
          isActive: true,
          startAt: now,
          endAt: now.add(Duration(seconds: event.durationSeconds)),
          displayDurationSeconds: event.durationSeconds,
        );
      }
      return a;
    }).toList();
    emit(
      state.copyWith(
        mosque: _withAlerts(m, list),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onAlertUnpublished(AlertUnpublished event, Emitter<AlertsState> emit) {
    final m = state.mosque;
    if (m == null) return;
    final now = DateTime.now();
    final list = m.savedAlerts.map((a) {
      if (a.id == event.alertId) {
        // Unpublishing means: take it out of its active window immediately.
        return a.copyWith(isActive: false, endAt: now);
      }
      return a;
    }).toList();
    emit(
      state.copyWith(
        mosque: _withAlerts(m, list),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onAlertUpdated(AlertUpdated event, Emitter<AlertsState> emit) {
    final m = state.mosque;
    if (m == null) return;
    final list = m.savedAlerts
        .map((a) => a.id == event.alert.id ? event.alert : a)
        .toList();
    emit(
      state.copyWith(
        mosque: _withAlerts(m, list),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onAllAlertsDeleted(AllAlertsDeleted event, Emitter<AlertsState> emit) {
    final m = state.mosque;
    if (m == null) return;
    emit(
      state.copyWith(
        mosque: _withAlerts(m, const []),
        hasUnsavedChanges: true,
      ),
    );
  }

  Future<void> _onSave(
    SaveAlertsRequested event,
    Emitter<AlertsState> emit,
  ) async {
    final m = state.mosque;
    if (m == null) return;
    await _saveRunner.run(
      checkConnectivity: false,
      onlineTask: (_) => _repo.updateActiveAlerts(m),
      onStart: () => emit(state.copyWith(isSaving: true)),
      onSuccess: (_) => emit(
        state.copyWith(isSaving: false, hasUnsavedChanges: false, error: null),
      ),
      onError: (error) =>
          emit(state.copyWith(isSaving: false, error: errorMessage(error))),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _saveRunner.cancel();
    return super.close();
  }
}
