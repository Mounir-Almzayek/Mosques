import 'package:equatable/equatable.dart';

enum TrackedVerseStatus { read, incorrect }

class TrackedVerse extends Equatable {
  final int surahNumber;
  final int verseNumber;
  final int pageNumber;
  final TrackedVerseStatus status;

  const TrackedVerse({
    required this.surahNumber,
    required this.verseNumber,
    required this.pageNumber,
    required this.status,
  });

  String get id => '$surahNumber:$verseNumber';

  TrackedVerse copyWith({TrackedVerseStatus? status}) {
    return TrackedVerse(
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      pageNumber: pageNumber,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [surahNumber, verseNumber, pageNumber, status];
}
