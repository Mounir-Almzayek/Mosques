import 'package:equatable/equatable.dart';

abstract class ImamTrackingEvent extends Equatable {
  const ImamTrackingEvent();

  @override
  List<Object?> get props => [];
}

class LoadImamTracking extends ImamTrackingEvent {
  const LoadImamTracking();
}

class ToggleRecording extends ImamTrackingEvent {
  const ToggleRecording();
}

class SelectPage extends ImamTrackingEvent {
  final int pageNumber;

  const SelectPage(this.pageNumber);

  @override
  List<Object?> get props => [pageNumber];
}

class AdvanceHighlightedVerse extends ImamTrackingEvent {
  const AdvanceHighlightedVerse();
}

class MarkVerseRead extends ImamTrackingEvent {
  final int surahNumber;
  final int verseNumber;

  const MarkVerseRead(this.surahNumber, this.verseNumber);

  @override
  List<Object?> get props => [surahNumber, verseNumber];
}

class MarkVerseIncorrect extends ImamTrackingEvent {
  final int surahNumber;
  final int verseNumber;

  const MarkVerseIncorrect(this.surahNumber, this.verseNumber);

  @override
  List<Object?> get props => [surahNumber, verseNumber];
}
