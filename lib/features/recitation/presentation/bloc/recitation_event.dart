import 'package:equatable/equatable.dart';

import '../../../../data/models/mosque/imam_tracking_session_model.dart';

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

class StartImamDisplay extends ImamTrackingEvent {
  const StartImamDisplay();
}

class StopImamDisplay extends ImamTrackingEvent {
  const StopImamDisplay();
}

class ImamTrackingSessionUpdated extends ImamTrackingEvent {
  final ImamTrackingSessionModel session;

  const ImamTrackingSessionUpdated(this.session);

  @override
  List<Object?> get props => [session];
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
