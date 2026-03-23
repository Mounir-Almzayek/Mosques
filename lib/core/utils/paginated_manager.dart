import 'package:flutter/foundation.dart';

class PaginatedManager<T> {
  int currentPage;
  final int pageSize;
  bool hasMoreData;
  final bool enableLogging;
  List<T> data;

  PaginatedManager({
    this.pageSize = 15,
    this.enableLogging = true,
  })  : currentPage = 1,
        hasMoreData = true,
        data = [];

  void _log(String message) {
    if (enableLogging) {
      if (kDebugMode) {
        print("[PaginatedAsyncManager] $message");
      }
    }
  }

  Future<void> loadPage({
    required Future<List<T>> Function(int page, int pageSize) task,
    void Function()? onStart,
  }) async {
    if (currentPage == 1) resetPagination();

    _log("Starting to load page: $currentPage");
    onStart?.call();

    try {
      List<T> newItems = await task(currentPage, pageSize);
      _log("Loaded ${newItems.length} items on page $currentPage");

      data.addAll(newItems);
      _log("Total data now: ${data.length}");

      if (newItems.length < pageSize) {
        hasMoreData = false;
        _log(
            "No more data available. Items returned: ${newItems.length}, expected: $pageSize");
      } else {
        _log(
            "More data available. Items returned: ${newItems.length}, expected: $pageSize");
      }
      if (hasMoreData) {
        currentPage++;
        _log("Moving to next page: $currentPage");
      }
    } catch (e) {
      _log("Error loading page $currentPage: $e");
    }
  }

  void resetPagination() {
    _log("Resetting pagination.");
    currentPage = 1;
    hasMoreData = true;
    data.clear();
  }
}
