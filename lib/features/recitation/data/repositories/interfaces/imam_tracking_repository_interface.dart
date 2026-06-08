import '../../models/tracked_verse.dart';

abstract class IImamTrackingRepository {
  Future<int> getLastPage();
  Future<void> saveLastPage(int pageNumber);
  List<TrackedVerse> getPageVerses(int pageNumber);
}
