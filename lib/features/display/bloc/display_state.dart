import 'package:equatable/equatable.dart';

import '../../../data/models/announcement_model.dart';
import '../../../data/models/mosque_model.dart';

/// Base class for all display-screen states.
abstract class DisplayState extends Equatable {
  const DisplayState();

  @override
  List<Object?> get props => [];
}

class DisplayInitial extends DisplayState {}

class DisplayLoading extends DisplayState {}

/// Successfully loaded mosque data, optionally with platform announcements.
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
