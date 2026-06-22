import 'package:equatable/equatable.dart';

class AdministrativeDivision extends Equatable {
  final String id;
  final String countryCode;
  final int adminLevel;
  final String sourceCode;
  final String name;
  final String? nameEn;
  final String? nameAr;
  final String? parentId;
  final String? centerLat;
  final String? centerLon;
  final List<AdministrativeDivision> path;

  const AdministrativeDivision({
    required this.id,
    required this.countryCode,
    required this.adminLevel,
    required this.sourceCode,
    required this.name,
    this.nameEn,
    this.nameAr,
    this.parentId,
    this.centerLat,
    this.centerLon,
    this.path = const [],
  });

  String get displayName {
    final ar = nameAr?.trim();
    if (ar != null && ar.isNotEmpty) return ar;
    final base = name.trim();
    if (base.isNotEmpty) return base;
    final en = nameEn?.trim();
    if (en != null && en.isNotEmpty) return en;
    return sourceCode;
  }

  double? get latitudeValue => double.tryParse(centerLat ?? '');
  double? get longitudeValue => double.tryParse(centerLon ?? '');

  factory AdministrativeDivision.fromJson(Map<String, dynamic> json) {
    final rawPath = json['path'];
    return AdministrativeDivision(
      id: json['id']?.toString() ?? '',
      countryCode: json['countryCode']?.toString() ?? 'SY',
      adminLevel: (json['adminLevel'] as num?)?.toInt() ?? 0,
      sourceCode: json['sourceCode']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameEn: json['nameEn']?.toString(),
      nameAr: json['nameAr']?.toString(),
      parentId: json['parentId']?.toString(),
      centerLat: json['centerLat']?.toString(),
      centerLon: json['centerLon']?.toString(),
      path: rawPath is List
          ? rawPath
                .whereType<Map>()
                .map(
                  (item) => AdministrativeDivision.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'countryCode': countryCode,
    'adminLevel': adminLevel,
    'sourceCode': sourceCode,
    'name': name,
    'nameEn': nameEn,
    'nameAr': nameAr,
    'parentId': parentId,
    'centerLat': centerLat,
    'centerLon': centerLon,
    if (path.isNotEmpty) 'path': path.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    id,
    countryCode,
    adminLevel,
    sourceCode,
    name,
    nameEn,
    nameAr,
    parentId,
    centerLat,
    centerLon,
    path,
  ];
}
