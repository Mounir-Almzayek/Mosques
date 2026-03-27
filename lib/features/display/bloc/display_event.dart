import 'package:equatable/equatable.dart';

import '../../../data/models/announcement_model.dart';
import '../../../data/models/mosque_model.dart';

/// Base class for all display-screen events.
abstract class DisplayEvent extends Equatable {
  const DisplayEvent();

  @override
  List<Object?> get props => [];
}

/// Initiates Firestore subscriptions for mosque data and platform announcements.
class StartDisplaySubscription extends DisplayEvent {}

/// Fired when the mosque document snapshot changes (or from the hourly fetch).
class MosqueUpdated extends DisplayEvent {
  final MosqueModel? mosque;

  const MosqueUpdated(this.mosque);

  @override
  List<Object?> get props => [mosque];
}

/// Fired when the platform-wide announcements stream emits.
class PlatformAnnouncementsUpdated extends DisplayEvent {
  final List<AnnouncementModel> announcements;

  const PlatformAnnouncementsUpdated(this.announcements);

  @override
  List<Object?> get props => [announcements];
}

/// Fired on subscription errors.
class DisplayErrorEvent extends DisplayEvent {
  final String message;

  const DisplayErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
