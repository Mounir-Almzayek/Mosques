import 'package:equatable/equatable.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';

import '../../data/models/tracked_verse.dart';

class ImamTrackingState extends Equatable {
  final int currentPage;
  final int currentVerseIndex;
  final bool isRecording;
  final bool isLoading;
  final DateTime? lastRecordedAt;
  final List<TrackedVerse> trackedVerses;

  const ImamTrackingState({
    this.currentPage = 1,
    this.currentVerseIndex = 0,
    this.isRecording = false,
    this.isLoading = true,
    this.lastRecordedAt,
    this.trackedVerses = const [],
  });

  int get totalPages => totalPagesCount;

  ImamTrackingState copyWith({
    int? currentPage,
    int? currentVerseIndex,
    bool? isRecording,
    bool? isLoading,
    DateTime? lastRecordedAt,
    List<TrackedVerse>? trackedVerses,
  }) {
    return ImamTrackingState(
      currentPage: currentPage ?? this.currentPage,
      currentVerseIndex: currentVerseIndex ?? this.currentVerseIndex,
      isRecording: isRecording ?? this.isRecording,
      isLoading: isLoading ?? this.isLoading,
      lastRecordedAt: lastRecordedAt ?? this.lastRecordedAt,
      trackedVerses: trackedVerses ?? this.trackedVerses,
    );
  }

  @override
  List<Object?> get props => [
    currentPage,
    currentVerseIndex,
    isRecording,
    isLoading,
    lastRecordedAt,
    trackedVerses,
  ];
}
