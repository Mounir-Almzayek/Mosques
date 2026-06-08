import 'package:Tebyan/data/models/mosque/imam_tracking_session_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('imam tracking session round-trips active state and errors', () {
    const session = ImamTrackingSessionModel(
      isActive: true,
      isRecording: true,
      currentPage: 50,
      highlightedVerse: ImamTrackingVerseModel(
        surahNumber: 2,
        verseNumber: 11,
        pageNumber: 3,
      ),
      trackedVerses: [
        ImamTrackingVerseModel(
          surahNumber: 2,
          verseNumber: 12,
          pageNumber: 3,
          isIncorrect: true,
        ),
      ],
    );

    expect(ImamTrackingSessionModel.fromMap(session.toMap()), session);
  });
}
