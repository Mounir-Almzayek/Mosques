import 'package:equatable/equatable.dart';

import '../../../../core/widgets/quran/tracked_verse.dart';

class RecitationState extends Equatable {
  final bool isStarting;
  final bool isTracking;
  final String? requestId;
  final String? aiSessionId;
  final String? errorMessage;
  final Map<String, dynamic>? lastEvent;
  final int currentPage;
  final TrackedVerse? highlightedVerse;

  const RecitationState({
    this.isStarting = false,
    this.isTracking = false,
    this.requestId,
    this.aiSessionId,
    this.errorMessage,
    this.lastEvent,
    this.currentPage = 1,
    this.highlightedVerse,
  });

  RecitationState copyWith({
    bool? isStarting,
    bool? isTracking,
    String? requestId,
    String? aiSessionId,
    String? errorMessage,
    bool clearError = false,
    Map<String, dynamic>? lastEvent,
    int? currentPage,
    TrackedVerse? highlightedVerse,
  }) {
    return RecitationState(
      isStarting: isStarting ?? this.isStarting,
      isTracking: isTracking ?? this.isTracking,
      requestId: requestId ?? this.requestId,
      aiSessionId: aiSessionId ?? this.aiSessionId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      lastEvent: lastEvent ?? this.lastEvent,
      currentPage: currentPage ?? this.currentPage,
      highlightedVerse: highlightedVerse ?? this.highlightedVerse,
    );
  }

  @override
  List<Object?> get props => [
    isStarting,
    isTracking,
    requestId,
    aiSessionId,
    errorMessage,
    lastEvent,
    currentPage,
    highlightedVerse,
  ];
}
