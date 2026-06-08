import 'package:equatable/equatable.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';

import '../../data/models/tracked_verse.dart';

class ImamTrackingState extends Equatable {
  final int currentPage;
  final int currentVerseIndex;
  final bool isRecording;
  final bool isLoading;
  final bool isDisplayActive;
  final bool isPublishing;
  final String? publishError;
  final DateTime? lastRecordedAt;
  final TrackedVerse? highlightedVerse;
  final List<TrackedVerse> trackedVerses;

  const ImamTrackingState({
    this.currentPage = 1,
    this.currentVerseIndex = 0,
    this.isRecording = false,
    this.isLoading = true,
    this.isDisplayActive = false,
    this.isPublishing = false,
    this.publishError,
    this.lastRecordedAt,
    this.highlightedVerse,
    this.trackedVerses = const [],
  });

  int get totalPages => totalPagesCount;

  ImamTrackingState copyWith({
    int? currentPage,
    int? currentVerseIndex,
    bool? isRecording,
    bool? isLoading,
    bool? isDisplayActive,
    bool? isPublishing,
    String? publishError,
    DateTime? lastRecordedAt,
    TrackedVerse? highlightedVerse,
    bool clearHighlightedVerse = false,
    List<TrackedVerse>? trackedVerses,
  }) {
    return ImamTrackingState(
      currentPage: currentPage ?? this.currentPage,
      currentVerseIndex: currentVerseIndex ?? this.currentVerseIndex,
      isRecording: isRecording ?? this.isRecording,
      isLoading: isLoading ?? this.isLoading,
      isDisplayActive: isDisplayActive ?? this.isDisplayActive,
      isPublishing: isPublishing ?? this.isPublishing,
      publishError: publishError,
      lastRecordedAt: lastRecordedAt ?? this.lastRecordedAt,
      highlightedVerse: clearHighlightedVerse
          ? null
          : highlightedVerse ?? this.highlightedVerse,
      trackedVerses: trackedVerses ?? this.trackedVerses,
    );
  }

  @override
  List<Object?> get props => [
    currentPage,
    currentVerseIndex,
    isRecording,
    isLoading,
    isDisplayActive,
    isPublishing,
    publishError,
    lastRecordedAt,
    highlightedVerse,
    trackedVerses,
  ];
}
