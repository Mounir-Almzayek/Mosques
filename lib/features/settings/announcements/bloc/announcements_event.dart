import 'package:equatable/equatable.dart';

import '../../../../data/models/mosque/mosque_model.dart';

sealed class AnnouncementsEvent extends Equatable {
  const AnnouncementsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnnouncements extends AnnouncementsEvent {
  const LoadAnnouncements();
}

class AnnouncementAdded extends AnnouncementsEvent {
  final AnnouncementModel announcement;

  const AnnouncementAdded(this.announcement);

  @override
  List<Object?> get props => [announcement];
}

class AnnouncementUpdated extends AnnouncementsEvent {
  final AnnouncementModel announcement;

  const AnnouncementUpdated(this.announcement);

  @override
  List<Object?> get props => [announcement];
}

class AnnouncementRemoved extends AnnouncementsEvent {
  final String announcementId;

  const AnnouncementRemoved(this.announcementId);

  @override
  List<Object?> get props => [announcementId];
}

class SaveAnnouncementsRequested extends AnnouncementsEvent {
  const SaveAnnouncementsRequested();
}

/// Internal event emitted when the mosque stream pushes a new value.
class AnnouncementsMosqueUpdated extends AnnouncementsEvent {
  final MosqueModel? mosque;

  const AnnouncementsMosqueUpdated(this.mosque);

  @override
  List<Object?> get props => [mosque];
}
