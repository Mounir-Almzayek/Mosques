import 'package:equatable/equatable.dart';

abstract class RecitationEvent extends Equatable {
  const RecitationEvent();

  @override
  List<Object?> get props => [];
}

class StartRecitationTracking extends RecitationEvent {
  final int surah;
  final int ayah;
  final int wordIndex;

  const StartRecitationTracking({
    required this.surah,
    required this.ayah,
    this.wordIndex = 0,
  });

  @override
  List<Object?> get props => [surah, ayah, wordIndex];
}

class StopRecitationTracking extends RecitationEvent {
  const StopRecitationTracking();
}

class RecitationAiEventReceived extends RecitationEvent {
  final Map<String, dynamic> event;

  const RecitationAiEventReceived(this.event);

  @override
  List<Object?> get props => [event];
}

class RecitationPageSelected extends RecitationEvent {
  final int pageNumber;

  const RecitationPageSelected(this.pageNumber);

  @override
  List<Object?> get props => [pageNumber];
}

class RecitationFailed extends RecitationEvent {
  final String message;

  const RecitationFailed(this.message);

  @override
  List<Object?> get props => [message];
}
