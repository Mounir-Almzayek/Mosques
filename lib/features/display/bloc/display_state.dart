import 'package:equatable/equatable.dart';

import '../../../core/widgets/quran/tracked_verse.dart';
import '../../../data/models/app/app_config.dart';
import '../../../data/models/mosque/mosque_bootstrap.dart';

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
  final MosqueBootstrap mosque;
  final List<Announcement> platformAnnouncements;
  final AppConfig? appSettings;
  final String? currentVersion;
  final DisplayRecitationState? recitation;

  const DisplayLoaded(
    this.mosque, {
    this.platformAnnouncements = const [],
    this.appSettings,
    this.currentVersion,
    this.recitation,
  });

  @override
  List<Object?> get props => [
    mosque,
    platformAnnouncements,
    appSettings,
    currentVersion,
    recitation,
  ];
}

class DisplayError extends DisplayState {
  final String message;

  const DisplayError(this.message);

  @override
  List<Object?> get props => [message];
}

class DisplayRecitationState extends Equatable {
  final int currentPage;
  final TrackedVerse? highlightedVerse;
  final Map<String, dynamic> event;

  const DisplayRecitationState({
    required this.currentPage,
    required this.event,
    this.highlightedVerse,
  });

  String get eventType => event['type']?.toString() ?? '';

  @override
  List<Object?> get props => [currentPage, highlightedVerse, event];
}
