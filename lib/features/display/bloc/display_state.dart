import 'package:equatable/equatable.dart';

import '../../../data/models/app/app_settings_model.dart';
import '../../../data/models/mosque/announcement_model.dart';
import '../../../data/models/mosque/mosque_model.dart';

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
  final AppSettingsModel? appSettings;
  final String? currentVersion;

  const DisplayLoaded(
    this.mosque, {
    this.platformAnnouncements = const [],
    this.appSettings,
    this.currentVersion,
  });

  @override
  List<Object?> get props =>
      [mosque, platformAnnouncements, appSettings, currentVersion];
}

class DisplayError extends DisplayState {
  final String message;

  const DisplayError(this.message);

  @override
  List<Object?> get props => [message];
}
