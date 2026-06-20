import 'package:equatable/equatable.dart';

import '../../../core/utils/date_parse.dart';

/// Mosque profile — 1:1 with the backend `MosqueSummaryResponse` /
/// `DisplayMosqueResponse` DTO.
///
/// `latitude`/`longitude` are kept as `String` exactly as the backend sends
/// them; use [latitudeValue]/[longitudeValue] for the parsed doubles needed by
/// prayer-time math.
class Mosque extends Equatable {
  final String id;
  final String publicSlug;
  final String name;
  final String city;
  final String? countryCode;
  final String latitude;
  final String longitude;
  final String timezone;
  final String languageCode;
  final String defaultRiwayahCode;
  final String? ownerUserId;
  final int syncRevision;
  final DateTime? updatedAt;

  const Mosque({
    this.id = '',
    this.publicSlug = '',
    this.name = '',
    this.city = '',
    this.countryCode,
    this.latitude = '0',
    this.longitude = '0',
    this.timezone = 'Asia/Damascus',
    this.languageCode = 'ar',
    this.defaultRiwayahCode = 'hafs',
    this.ownerUserId,
    this.syncRevision = 1,
    this.updatedAt,
  });

  double get latitudeValue => double.tryParse(latitude) ?? 0;
  double get longitudeValue => double.tryParse(longitude) ?? 0;

  factory Mosque.fromJson(Map<String, dynamic> json) {
    return Mosque(
      id: json['id']?.toString() ?? '',
      publicSlug: json['publicSlug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      countryCode: json['countryCode']?.toString(),
      latitude: json['latitude']?.toString() ?? '0',
      longitude: json['longitude']?.toString() ?? '0',
      timezone: json['timezone']?.toString() ?? 'Asia/Damascus',
      languageCode: json['languageCode']?.toString() ?? 'ar',
      defaultRiwayahCode: json['defaultRiwayahCode']?.toString() ?? 'hafs',
      ownerUserId: json['ownerUserId']?.toString(),
      syncRevision: (json['syncRevision'] as num?)?.toInt() ?? 1,
      updatedAt: parseDateOrMillis(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'publicSlug': publicSlug,
      'name': name,
      'city': city,
      'countryCode': countryCode,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'languageCode': languageCode,
      'defaultRiwayahCode': defaultRiwayahCode,
      'ownerUserId': ownerUserId,
      'syncRevision': syncRevision,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Mosque copyWith({
    String? id,
    String? publicSlug,
    String? name,
    String? city,
    String? countryCode,
    String? latitude,
    String? longitude,
    String? timezone,
    String? languageCode,
    String? defaultRiwayahCode,
    String? ownerUserId,
    int? syncRevision,
    DateTime? updatedAt,
  }) {
    return Mosque(
      id: id ?? this.id,
      publicSlug: publicSlug ?? this.publicSlug,
      name: name ?? this.name,
      city: city ?? this.city,
      countryCode: countryCode ?? this.countryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
      languageCode: languageCode ?? this.languageCode,
      defaultRiwayahCode: defaultRiwayahCode ?? this.defaultRiwayahCode,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      syncRevision: syncRevision ?? this.syncRevision,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        publicSlug,
        name,
        city,
        countryCode,
        latitude,
        longitude,
        timezone,
        languageCode,
        defaultRiwayahCode,
        ownerUserId,
        syncRevision,
        updatedAt,
      ];
}
