import 'package:equatable/equatable.dart';

import '../../../data/models/app/app_config.dart';
import '../../../data/models/mosque/mosque_bootstrap.dart';

/// Base class for all display-screen events.
abstract class DisplayEvent extends Equatable {
  const DisplayEvent();

  @override
  List<Object?> get props => [];
}

/// Initiates backend subscriptions for mosque data and platform announcements.
class StartDisplaySubscription extends DisplayEvent {}

/// Fired when the mosque snapshot changes (or from the hourly fetch).
class MosqueUpdated extends DisplayEvent {
  final MosqueBootstrap? mosque;

  const MosqueUpdated(this.mosque);

  @override
  List<Object?> get props => [mosque];
}

/// Fired when the platform-wide announcements stream emits.
class PlatformAnnouncementsUpdated extends DisplayEvent {
  final List<Announcement> announcements;

  const PlatformAnnouncementsUpdated(this.announcements);

  @override
  List<Object?> get props => [announcements];
}

/// Fired when global app config changes.
class AppSettingsUpdated extends DisplayEvent {
  final AppConfig? settings;

  const AppSettingsUpdated(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// Fired when the current app version is retrieved.
class CurrentVersionUpdated extends DisplayEvent {
  final String version;

  const CurrentVersionUpdated(this.version);

  @override
  List<Object?> get props => [version];
}

class RecitationDisplayEventUpdated extends DisplayEvent {
  final Map<String, dynamic>? event;

  const RecitationDisplayEventUpdated(this.event);

  @override
  List<Object?> get props => [event];
}

/// Fired on subscription errors.
class DisplayErrorEvent extends DisplayEvent {
  final String message;

  const DisplayErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
