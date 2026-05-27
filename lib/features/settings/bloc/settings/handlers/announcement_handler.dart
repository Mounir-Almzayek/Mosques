import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/models/mosque/mosque_model.dart';
import '../../../models/settings_edit_request.dart';
import '../settings_event.dart';
import '../settings_state.dart';

/// Mixin handling both normal announcements and high-priority instant alerts.
mixin AnnouncementHandler on Bloc<SettingsEvent, SettingsState> {
  void Function(Emitter<SettingsState> emit, SettingsEditRequest next)
  get emitDraftUpdated;
  MosqueModel? get currentMosque;

  void onAnnouncementAdded(
    AnnouncementAdded event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final list = List<AnnouncementModel>.from(m.announcements)
      ..add(event.announcement);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(announcements: list)),
    );
  }

  void onAnnouncementUpdated(
    AnnouncementUpdated event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final list = m.announcements
        .map((a) => a.id == event.announcement.id ? event.announcement : a)
        .toList();
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(announcements: list)),
    );
  }

  void onAnnouncementRemoved(
    AnnouncementRemoved event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    final list = m.announcements
        .where((a) => a.id != event.announcementId)
        .toList();
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(announcements: list)),
    );
  }

  // --- Instant Alerts ---

  void onAlertAdded(AlertAdded event, Emitter<SettingsState> emit) {
    final m = currentMosque;
    if (m == null) return;
    final list = List<AnnouncementModel>.from(m.savedAlerts)..add(event.alert);
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(savedAlerts: list)),
    );
  }

  void onAlertRemoved(AlertRemoved event, Emitter<SettingsState> emit) {
    final m = currentMosque;
    if (m == null) return;
    final list = m.savedAlerts.where((a) => a.id != event.alertId).toList();
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(savedAlerts: list)),
    );
  }

  void onAlertsCleared(
    AlertsCleared event,
    Emitter<SettingsState> emit,
  ) {
    final m = currentMosque;
    if (m == null) return;
    emitDraftUpdated(
      emit,
      state.request.copyWith(mosque: m.copyWith(savedAlerts: [])),
    );
  }
}
