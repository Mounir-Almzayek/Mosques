import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../core/utils/firestore_date_parse.dart';
import 'announcement_model.dart';
import 'design_settings_model.dart';
import 'hadith_model.dart';
import 'iqama_settings_model.dart';
import 'mosque_text_list_kind.dart';

export 'announcement_model.dart';
export 'design_settings_model.dart';
export 'hadith_model.dart';
export 'iqama_settings_model.dart';
export 'mosque_text_list_kind.dart';

class MosqueModel extends Equatable {
  final String id;
  final String name;
  final String city;
  final double latitude;
  final double longitude;
  final String prayerCalculationMethod;
  /// UI language override for this mosque.
  /// Stored in Firestore as `language_code` (or legacy `app_language_code`).
  final String? appLanguageCode;
  final DesignSettingsModel designSettings;
  final IqamaSettingsModel iqamaSettings;
  final List<HadithModel> hadiths;
  final List<VerseModel> verses;
  final List<DuaModel> duas;
  final List<AdhkarModel> adhkar;
  final List<AnnouncementModel> announcements;
  final DateTime? lastSeen;
  final DateTime? updatedAt;

  const MosqueModel({
    required this.id,
    required this.name,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.prayerCalculationMethod,
    required this.appLanguageCode,
    required this.designSettings,
    required this.iqamaSettings,
    this.hadiths = const [],
    this.verses = const [],
    this.duas = const [],
    this.adhkar = const [],
    this.announcements = const [],
    this.lastSeen,
    this.updatedAt,
  });

  factory MosqueModel.fromMap(Map<String, dynamic> map, String id) {
    final rawLang = map['language_code'] ?? map['app_language_code'];
    return MosqueModel(
      id: id,
      name: map['name'] ?? '',
      city: map['city'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      prayerCalculationMethod: map['calculation_method'] ?? 'MuslimWorldLeague',
      appLanguageCode:
          (rawLang is String && rawLang.isNotEmpty) ? rawLang : null,
      designSettings: DesignSettingsModel.fromMap(map['design_settings'] ?? {}),
      iqamaSettings: IqamaSettingsModel.fromMap(map['iqama_offsets'] ?? {}),
      hadiths: (map['hadiths'] as List<dynamic>?)
              ?.map((e) => HadithModel.fromMap(e as Map<String, dynamic>, e['id'] ?? ''))
              .toList() ??
          [],
      verses: (map['verses'] as List<dynamic>?)
              ?.map((e) => VerseModel.fromMap(e as Map<String, dynamic>, e['id'] ?? ''))
              .toList() ??
          [],
      duas: (map['duas'] as List<dynamic>?)
              ?.map((e) => DuaModel.fromMap(e as Map<String, dynamic>, e['id'] ?? ''))
              .toList() ??
          [],
      adhkar: (map['adhkar'] as List<dynamic>?)
              ?.map((e) => AdhkarModel.fromMap(e as Map<String, dynamic>, e['id'] ?? ''))
              .toList() ??
          [],
      announcements: (map['mosque_ads'] as List<dynamic>?)
              ?.map((e) => AnnouncementModel.fromMap(e as Map<String, dynamic>, e['id'] ?? ''))
              .toList() ??
          [],
      lastSeen: parseFirestoreOrMillis(map['last_seen']),
      updatedAt: parseFirestoreOrMillis(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    final data = {
      'name': name,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'calculation_method': prayerCalculationMethod,
      'design_settings': designSettings.toMap(),
      'iqama_offsets': iqamaSettings.toMap(),
      'hadiths': hadiths.map((h) => h.toMap()).toList(),
      'verses': verses.map((v) => v.toMap()).toList(),
      'duas': duas.map((d) => d.toMap()).toList(),
      'adhkar': adhkar.map((a) => a.toMap()).toList(),
      'mosque_ads': announcements.map((a) => a.toMap()).toList(),
      'last_seen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
    if (appLanguageCode != null) {
      data['language_code'] = appLanguageCode;
    }
    return data;
  }

  List<MosqueTextEntryModel> listByKind(MosqueTextListKind kind) {
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

  MosqueModel copyWith({
    String? name,
    String? city,
    double? latitude,
    double? longitude,
    String? prayerCalculationMethod,
    String? appLanguageCode,
    DesignSettingsModel? designSettings,
    IqamaSettingsModel? iqamaSettings,
    List<HadithModel>? hadiths,
    List<VerseModel>? verses,
    List<DuaModel>? duas,
    List<AdhkarModel>? adhkar,
    List<AnnouncementModel>? announcements,
    DateTime? lastSeen,
    DateTime? updatedAt,
  }) {
    return MosqueModel(
      id: id,
      name: name ?? this.name,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      prayerCalculationMethod: prayerCalculationMethod ?? this.prayerCalculationMethod,
      appLanguageCode: appLanguageCode ?? this.appLanguageCode,
      designSettings: designSettings ?? this.designSettings,
      iqamaSettings: iqamaSettings ?? this.iqamaSettings,
      hadiths: hadiths ?? this.hadiths,
      verses: verses ?? this.verses,
      duas: duas ?? this.duas,
      adhkar: adhkar ?? this.adhkar,
      announcements: announcements ?? this.announcements,
      lastSeen: lastSeen ?? this.lastSeen,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        city,
        latitude,
        longitude,
        prayerCalculationMethod,
        appLanguageCode,
        designSettings,
        iqamaSettings,
        hadiths,
        verses,
        duas,
        adhkar,
        announcements,
        lastSeen,
        updatedAt,
      ];
}
