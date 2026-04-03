import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/hive_service.dart';
import '../models/announcement_model.dart';

class PlatformAnnouncementsLocalRepository {
  PlatformAnnouncementsLocalRepository._();

  static const String _cacheKey = 'platform_announcements_cache_v1';

  static dynamic _sanitizeForHive(dynamic value) {
    if (value is Timestamp) {
      return value.millisecondsSinceEpoch;
    }
    if (value is DateTime) {
      return value.millisecondsSinceEpoch;
    }
    if (value is Map) {
      final m = <String, dynamic>{};
      value.forEach((k, v) {
        m[k.toString()] = _sanitizeForHive(v);
      });
      return m;
    }
    if (value is List) {
      return value.map(_sanitizeForHive).toList();
    }
    return value;
  }

  static Future<void> saveAnnouncements(List<AnnouncementModel> list) async {
    final rawList = list.map((a) {
      final map = a.toMap();
      map['id'] = a.id; 
      return map;
    }).toList();
    
    final storable = _sanitizeForHive(rawList) as List<dynamic>;
    await HiveService.saveData(_cacheKey, storable);
  }

  static Future<List<AnnouncementModel>?> getCached() async {
    final raw = await HiveService.getData(_cacheKey);
    if (raw is! List) return null;

    final list = raw.whereType<Map>().map((m) {
      final map = Map<String, dynamic>.from(m);
      final id = map['id']?.toString() ?? '';
      
      // Need to convert millisecondsSinceEpoch back to Timestamp for fromMap
      final convertedMap = <String, dynamic>{};
      map.forEach((k, v) {
        if (k == 'start_date' || k == 'end_date' || k == 'created_at') {
          if (v is int) {
            convertedMap[k] = Timestamp.fromMillisecondsSinceEpoch(v);
          } else {
             convertedMap[k] = v;
          }
        } else {
          convertedMap[k] = v;
        }
      });
      
      return AnnouncementModel.fromMap(convertedMap, id);
    }).toList();
    
    return list;
  }

  static Future<void> clearCache() async {
    await HiveService.deleteData(_cacheKey);
  }
}
