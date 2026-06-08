import 'package:qcf_quran_lite/qcf_quran_lite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tracked_verse.dart';
import 'interfaces/imam_tracking_repository_interface.dart';

class ImamTrackingRepository implements IImamTrackingRepository {
  static const _lastPageKey = 'imam_tracking_last_quran_page';

  @override
  Future<int> getLastPage() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getInt(_lastPageKey) ?? 1).clamp(1, totalPagesCount);
  }

  @override
  Future<void> saveLastPage(int pageNumber) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(
      _lastPageKey,
      pageNumber.clamp(1, totalPagesCount),
    );
  }

  @override
  List<TrackedVerse> getPageVerses(int pageNumber) {
    final verses = <TrackedVerse>[];

    for (final rawEntry in getPageData(pageNumber)) {
      final entry = Map<String, dynamic>.from(rawEntry as Map);
      final surahNumber = entry['surah'] as int;
      final start = entry['start'] as int;
      final end = entry['end'] as int;

      for (var verseNumber = start; verseNumber <= end; verseNumber++) {
        verses.add(
          TrackedVerse(
            surahNumber: surahNumber,
            verseNumber: verseNumber,
            pageNumber: pageNumber,
            status: TrackedVerseStatus.read,
          ),
        );
      }
    }

    return verses;
  }
}
