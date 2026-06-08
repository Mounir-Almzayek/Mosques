import 'package:equatable/equatable.dart';

class ImamTrackingVerseModel extends Equatable {
  final int surahNumber;
  final int verseNumber;
  final int pageNumber;
  final bool isIncorrect;

  const ImamTrackingVerseModel({
    required this.surahNumber,
    required this.verseNumber,
    required this.pageNumber,
    this.isIncorrect = false,
  });

  factory ImamTrackingVerseModel.fromMap(Map<String, dynamic> map) {
    return ImamTrackingVerseModel(
      surahNumber: (map['surah_number'] as num?)?.toInt() ?? 1,
      verseNumber: (map['verse_number'] as num?)?.toInt() ?? 1,
      pageNumber: (map['page_number'] as num?)?.toInt() ?? 1,
      isIncorrect: map['is_incorrect'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'surah_number': surahNumber,
      'verse_number': verseNumber,
      'page_number': pageNumber,
      'is_incorrect': isIncorrect,
    };
  }

  @override
  List<Object> get props => [surahNumber, verseNumber, pageNumber, isIncorrect];
}

class ImamTrackingSessionModel extends Equatable {
  final bool isActive;
  final bool isRecording;
  final int currentPage;
  final ImamTrackingVerseModel? highlightedVerse;
  final List<ImamTrackingVerseModel> trackedVerses;

  const ImamTrackingSessionModel({
    this.isActive = false,
    this.isRecording = false,
    this.currentPage = 1,
    this.highlightedVerse,
    this.trackedVerses = const [],
  });

  factory ImamTrackingSessionModel.fromMap(Map<String, dynamic> map) {
    return ImamTrackingSessionModel(
      isActive: map['is_active'] == true,
      isRecording: map['is_recording'] == true,
      currentPage: ((map['current_page'] as num?)?.toInt() ?? 1).clamp(1, 604),
      highlightedVerse: map['highlighted_verse'] is Map
          ? ImamTrackingVerseModel.fromMap(
              Map<String, dynamic>.from(map['highlighted_verse'] as Map),
            )
          : null,
      trackedVerses:
          (map['tracked_verses'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (item) => ImamTrackingVerseModel.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'is_active': isActive,
      'is_recording': isRecording,
      'current_page': currentPage,
      'highlighted_verse': highlightedVerse?.toMap(),
      'tracked_verses': trackedVerses.map((verse) => verse.toMap()).toList(),
    };
  }

  ImamTrackingSessionModel copyWith({
    bool? isActive,
    bool? isRecording,
    int? currentPage,
    ImamTrackingVerseModel? highlightedVerse,
    List<ImamTrackingVerseModel>? trackedVerses,
  }) {
    return ImamTrackingSessionModel(
      isActive: isActive ?? this.isActive,
      isRecording: isRecording ?? this.isRecording,
      currentPage: currentPage ?? this.currentPage,
      highlightedVerse: highlightedVerse ?? this.highlightedVerse,
      trackedVerses: trackedVerses ?? this.trackedVerses,
    );
  }

  @override
  List<Object?> get props => [
    isActive,
    isRecording,
    currentPage,
    highlightedVerse,
    trackedVerses,
  ];
}
