import 'package:equatable/equatable.dart';

import '../../../core/enums/settings/mosque_text_list_kind.dart';
import 'announcement.dart';
import 'content_item.dart';
import 'display_settings.dart';
import 'mosque.dart';
import 'prayer_settings.dart';

export '../../../core/enums/settings/mosque_text_list_kind.dart';
export 'announcement.dart';
export 'content_item.dart';
export 'display_settings.dart';
export 'mosque.dart';
export 'prayer_settings.dart';

/// Aggregate matching `GET /mobile/mosques/{id}/bootstrap` exactly
/// (`MosqueBootstrapResponse`). This is the unit the mosque repository caches
/// and that settings/display screens read sub-objects from.
class MosqueBootstrap extends Equatable {
  final Mosque mosque;
  final PrayerSettings prayerSettings;
  final DisplaySettings displaySettings;
  final List<ContentItem> content;
  final List<Announcement> announcements;
  final List<Announcement> platformAnnouncements;
  final int syncRevision;
  final String firestoreDocumentId;
  final DateTime? serverTime;

  const MosqueBootstrap({
    this.mosque = const Mosque(),
    this.prayerSettings = const PrayerSettings(),
    this.displaySettings = const DisplaySettings(),
    this.content = const [],
    this.announcements = const [],
    this.platformAnnouncements = const [],
    this.syncRevision = 1,
    this.firestoreDocumentId = '',
    this.serverTime,
  });

  // --- Convenience accessors (replace old MosqueModel getters) ---------------
  String get id => mosque.id;
  String get publicSlug => mosque.publicSlug;
  String get name => mosque.name;

  List<ContentItem> get hadiths => _byKind(const {'hadith'});
  List<ContentItem> get verses => _byKind(const {'ayah', 'verse'});
  List<ContentItem> get duas => _byKind(const {'dua'});
  List<ContentItem> get adhkar => _byKind(const {'dhikr', 'adhkar'});

  /// Regular mosque announcements rendered on the public display screen.
  List<Announcement> get ads => announcements
      .where((a) => !a.isAlert && a.audience == 'display')
      .toList();

  /// Mosque-scoped announcements intended for the imam/settings app.
  List<Announcement> get appAnnouncements =>
      announcements.where((a) => !a.isAlert && a.audience == 'imam').toList();

  /// Mosque alerts (`announcementType == 'alert'`).
  List<Announcement> get savedAlerts =>
      announcements.where((a) => a.isAlert && a.audience == 'display').toList();

  List<ContentItem> _byKind(Set<String> kinds) =>
      content.where((c) => kinds.contains(c.kind)).toList();

  List<ContentItem> listByKind(MosqueTextListKind kind) {
    switch (kind) {
      case MosqueTextListKind.hadith:
        return hadiths;
      case MosqueTextListKind.verse:
        return verses;
      case MosqueTextListKind.dua:
        return duas;
      case MosqueTextListKind.adhkar:
        return adhkar;
    }
  }

  factory MosqueBootstrap.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> asMap(Object? value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return const {};
    }

    List<Map<String, dynamic>> asList(Object? value) {
      if (value is! List) return const [];
      return value
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    final legacy = asMap(json['legacyCompatibility']);

    return MosqueBootstrap(
      mosque: Mosque.fromJson(asMap(json['mosque'])),
      prayerSettings: PrayerSettings.fromJson(asMap(json['prayerSettings'])),
      displaySettings: DisplaySettings.fromJson(asMap(json['displaySettings'])),
      content: asList(json['content']).map(ContentItem.fromJson).toList(),
      announcements: asList(
        json['announcements'],
      ).map(Announcement.fromJson).toList(),
      platformAnnouncements: asList(
        json['platformAnnouncements'],
      ).map(Announcement.fromJson).toList(),
      syncRevision: (json['syncRevision'] as num?)?.toInt() ?? 1,
      firestoreDocumentId: legacy['firestoreDocumentId']?.toString() ?? '',
      serverTime: _parseServerTime(json['serverTime']),
    );
  }

  static DateTime? _parseServerTime(Object? value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'mosque': mosque.toJson(),
    'prayerSettings': prayerSettings.toJson(),
    'displaySettings': displaySettings.toJson(),
    'content': content.map((c) => c.toJson()).toList(),
    'announcements': announcements.map((a) => a.toJson()).toList(),
    'platformAnnouncements': platformAnnouncements
        .map((a) => a.toJson())
        .toList(),
    'syncRevision': syncRevision,
    'legacyCompatibility': {'firestoreDocumentId': firestoreDocumentId},
    if (serverTime != null) 'serverTime': serverTime!.toIso8601String(),
  };

  MosqueBootstrap copyWith({
    Mosque? mosque,
    PrayerSettings? prayerSettings,
    DisplaySettings? displaySettings,
    List<ContentItem>? content,
    List<Announcement>? announcements,
    List<Announcement>? platformAnnouncements,
    int? syncRevision,
    String? firestoreDocumentId,
    DateTime? serverTime,
  }) {
    return MosqueBootstrap(
      mosque: mosque ?? this.mosque,
      prayerSettings: prayerSettings ?? this.prayerSettings,
      displaySettings: displaySettings ?? this.displaySettings,
      content: content ?? this.content,
      announcements: announcements ?? this.announcements,
      platformAnnouncements:
          platformAnnouncements ?? this.platformAnnouncements,
      syncRevision: syncRevision ?? this.syncRevision,
      firestoreDocumentId: firestoreDocumentId ?? this.firestoreDocumentId,
      serverTime: serverTime ?? this.serverTime,
    );
  }

  @override
  List<Object?> get props => [
    mosque,
    prayerSettings,
    displaySettings,
    content,
    announcements,
    platformAnnouncements,
    syncRevision,
    firestoreDocumentId,
    serverTime,
  ];
}
