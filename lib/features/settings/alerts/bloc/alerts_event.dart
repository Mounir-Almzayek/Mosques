import 'package:equatable/equatable.dart';

import '../../../../data/models/mosque/mosque_model.dart';

sealed class AlertsEvent extends Equatable {
  const AlertsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlerts extends AlertsEvent {
  const LoadAlerts();
}

class AlertAdded extends AlertsEvent {
  final AnnouncementModel alert;

  const AlertAdded(this.alert);

  @override
  List<Object?> get props => [alert];
}

class AlertRemoved extends AlertsEvent {
  final String alertId;

  const AlertRemoved(this.alertId);

  @override
  List<Object?> get props => [alertId];
}

class AlertPublished extends AlertsEvent {
  final String alertId;
  final int durationSeconds;

  const AlertPublished(this.alertId, this.durationSeconds);

  @override
  List<Object?> get props => [alertId, durationSeconds];
}

class AlertUnpublished extends AlertsEvent {
  final String alertId;

  const AlertUnpublished(this.alertId);

  @override
  List<Object?> get props => [alertId];
}

class AlertUpdated extends AlertsEvent {
  final AnnouncementModel alert;

  const AlertUpdated(this.alert);

  @override
  List<Object?> get props => [alert];
}

class AllAlertsDeleted extends AlertsEvent {
  const AllAlertsDeleted();
}

class SaveAlertsRequested extends AlertsEvent {
  const SaveAlertsRequested();
}

/// Internal event emitted when the mosque stream pushes a new value.
class AlertsMosqueUpdated extends AlertsEvent {
  final MosqueModel? mosque;

  const AlertsMosqueUpdated(this.mosque);

  @override
  List<Object?> get props => [mosque];
}
