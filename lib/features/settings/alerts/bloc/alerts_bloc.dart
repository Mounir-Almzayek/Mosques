import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/mosque/mosque_model.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'alerts_event.dart';
import 'alerts_state.dart';

export 'alerts_event.dart';
export 'alerts_state.dart';

class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  final IMosqueRepository _repo;

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

  Future<void> _onLoad(LoadAlerts event, Emitter<AlertsState> emit) async {
    _sub?.cancel();
    emit(state.copyWith(isLoading: true));
    _sub = _repo.streamActiveMosque.listen(
      (mosque) => add(AlertsMosqueUpdated(mosque)),
      onError: (Object error) =>
          emit(state.copyWith(isLoading: false, error: error.toString())),
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
    final list = List<AnnouncementModel>.from(m.savedAlerts)..add(event.alert);
    emit(
      state.copyWith(
        mosque: m.copyWith(savedAlerts: list),
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
        mosque: m.copyWith(savedAlerts: list),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onAlertPublished(AlertPublished event, Emitter<AlertsState> emit) {
    final m = state.mosque;
    if (m == null) return;
    final list = m.savedAlerts.map((a) {
      if (a.id == event.alertId) {
        return a.copyWith(
          isPublished: true,
          publishedAt: DateTime.now(),
          publishDurationSeconds: event.durationSeconds,
        );
      }
      return a;
    }).toList();
    emit(
      state.copyWith(
        mosque: m.copyWith(savedAlerts: list),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onAlertUnpublished(AlertUnpublished event, Emitter<AlertsState> emit) {
    final m = state.mosque;
    if (m == null) return;
    final list = m.savedAlerts.map((a) {
      if (a.id == event.alertId) {
        return a.copyWith(isPublished: false);
      }
      return a;
    }).toList();
    emit(
      state.copyWith(
        mosque: m.copyWith(savedAlerts: list),
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
        mosque: m.copyWith(savedAlerts: list),
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onAllAlertsDeleted(AllAlertsDeleted event, Emitter<AlertsState> emit) {
    final m = state.mosque;
    if (m == null) return;
    emit(
      state.copyWith(
        mosque: m.copyWith(savedAlerts: []),
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
    emit(state.copyWith(isSaving: true));
    try {
      await _repo.updateActiveAlerts(m);
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
