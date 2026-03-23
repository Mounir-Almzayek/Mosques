import 'package:hive_flutter/hive_flutter.dart';

/// Hive Service
/// Manages Hive database initialization and box operations
class HiveService {
  static const String _homeDataBoxName = 'home_data_box';
  static const String _requestQueueBoxName = 'request_queue_box';

  /// Initialize Hive database
  static Future<void> init() async {
    await Hive.initFlutter();
    // Pre-open the boxes to ensure they're ready
    if (!Hive.isBoxOpen(_homeDataBoxName)) {
      await Hive.openBox(_homeDataBoxName);
    }
    if (!Hive.isBoxOpen(_requestQueueBoxName)) {
      await Hive.openBox(_requestQueueBoxName);
    }
  }

  /// Get or open a box
  static Future<Box> _getBox([String? boxName]) async {
    final box = boxName ?? _homeDataBoxName;
    if (!Hive.isBoxOpen(box)) {
      return await Hive.openBox(box);
    }
    return Hive.box(box);
  }

  /// Get or open request queue box
  static Future<Box> getRequestQueueBox() async {
    return _getBox(_requestQueueBoxName);
  }

  /// Save data to box
  static Future<void> saveData(String key, dynamic value) async {
    final box = await _getBox();
    await box.put(key, value);
  }

  /// Get data from box
  static Future<dynamic> getData(String key) async {
    final box = await _getBox();
    return box.get(key);
  }

  /// Delete data from box
  static Future<void> deleteData(String key) async {
    final box = await _getBox();
    await box.delete(key);
  }

  /// Get all keys from the default (home data) box.
  static Future<List<String>> getDefaultBoxKeys() async {
    final box = await _getBox();
    return box.keys.map((e) => e.toString()).toList();
  }

  /// Clear all data from box
  static Future<void> clearBox() async {
    final box = await _getBox();
    await box.clear();
  }

  /// Close box
  static Future<void> closeBox() async {
    if (Hive.isBoxOpen(_homeDataBoxName)) {
      await Hive.box(_homeDataBoxName).close();
    }
  }
}
