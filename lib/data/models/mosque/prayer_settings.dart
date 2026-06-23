import 'package:equatable/equatable.dart';

/// Per-prayer minute adjustments — 1:1 with backend `PrayerOffsetsPayload`.
class PrayerOffsets extends Equatable {
  final int fajr;
  final int sunrise;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;

  const PrayerOffsets({
    this.fajr = 0,
    this.sunrise = 0,
    this.dhuhr = 0,
    this.asr = 0,
    this.maghrib = 0,
    this.isha = 0,
  });

  factory PrayerOffsets.fromJson(Map<String, dynamic> json) {
    int read(String key) => (json[key] as num?)?.toInt() ?? 0;
    return PrayerOffsets(
      fajr: read('fajr'),
      sunrise: read('sunrise'),
      dhuhr: read('dhuhr'),
      asr: read('asr'),
      maghrib: read('maghrib'),
      isha: read('isha'),
    );
  }

  Map<String, dynamic> toJson() => {
    'fajr': fajr,
    'sunrise': sunrise,
    'dhuhr': dhuhr,
    'asr': asr,
    'maghrib': maghrib,
    'isha': isha,
  };

  PrayerOffsets copyWith({
    int? fajr,
    int? sunrise,
    int? dhuhr,
    int? asr,
    int? maghrib,
    int? isha,
  }) {
    return PrayerOffsets(
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
    );
  }

  @override
  List<Object?> get props => [fajr, sunrise, dhuhr, asr, maghrib, isha];
}

/// Iqama offsets in minutes after adhan — 1:1 with backend
/// `IqamaOffsetsPayload`. Field names match the backend keys (no `Offset`
/// suffix).
class IqamaOffsets extends Equatable {
  final int fajr;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;
  final int jummah;

  const IqamaOffsets({
    this.fajr = 20,
    this.dhuhr = 15,
    this.asr = 15,
    this.maghrib = 10,
    this.isha = 15,
    this.jummah = 30,
  });

  factory IqamaOffsets.fromJson(Map<String, dynamic> json) {
    int read(String key, int fallback) =>
        (json[key] as num?)?.toInt() ?? fallback;
    return IqamaOffsets(
      fajr: read('fajr', 20),
      dhuhr: read('dhuhr', 15),
      asr: read('asr', 15),
      maghrib: read('maghrib', 10),
      isha: read('isha', 15),
      jummah: read('jummah', 30),
    );
  }

  Map<String, dynamic> toJson() => {
    'fajr': fajr,
    'dhuhr': dhuhr,
    'asr': asr,
    'maghrib': maghrib,
    'isha': isha,
    'jummah': jummah,
  };

  IqamaOffsets copyWith({
    int? fajr,
    int? dhuhr,
    int? asr,
    int? maghrib,
    int? isha,
    int? jummah,
  }) {
    return IqamaOffsets(
      fajr: fajr ?? this.fajr,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      jummah: jummah ?? this.jummah,
    );
  }

  @override
  List<Object?> get props => [fajr, dhuhr, asr, maghrib, isha, jummah];
}

/// Prayer + iqama settings — 1:1 with backend `PrayerSettingsResponse`.
class PrayerSettings extends Equatable {
  final String mosqueId;
  final String calculationMethod;
  final PrayerOffsets offsets;
  final IqamaOffsets iqamaOffsets;
  final int preAdhanMinutes;
  final int adhanMomentDurationSeconds;

  const PrayerSettings({
    this.mosqueId = '',
    this.calculationMethod = 'MuslimWorldLeague',
    this.offsets = const PrayerOffsets(),
    this.iqamaOffsets = const IqamaOffsets(),
    this.preAdhanMinutes = 10,
    this.adhanMomentDurationSeconds = 120,
  });

  factory PrayerSettings.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> readMap(String key) {
      final value = json[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return const {};
    }

    return PrayerSettings(
      mosqueId: json['mosqueId']?.toString() ?? '',
      calculationMethod:
          json['calculationMethod']?.toString() ?? 'MuslimWorldLeague',
      offsets: PrayerOffsets.fromJson(readMap('offsets')),
      iqamaOffsets: IqamaOffsets.fromJson(readMap('iqamaOffsets')),
      preAdhanMinutes: (json['preAdhanMinutes'] as num?)?.toInt() ?? 10,
      adhanMomentDurationSeconds:
          (json['adhanMomentDurationSeconds'] as num?)?.toInt() ?? 120,
    );
  }

  Map<String, dynamic> toJson() => {
    'mosqueId': mosqueId,
    'calculationMethod': calculationMethod,
    'offsets': offsets.toJson(),
    'iqamaOffsets': iqamaOffsets.toJson(),
    'preAdhanMinutes': preAdhanMinutes,
    'adhanMomentDurationSeconds': adhanMomentDurationSeconds,
  };

  /// Backend write body for `PUT .../prayer-settings` (no `mosqueId`).
  Map<String, dynamic> toRequestBody() => {
    'calculationMethod': calculationMethod,
    'offsets': offsets.toJson(),
    'iqamaOffsets': iqamaOffsets.toJson(),
    'preAdhanMinutes': preAdhanMinutes,
    'adhanMomentDurationSeconds': adhanMomentDurationSeconds,
  };

  PrayerSettings copyWith({
    String? mosqueId,
    String? calculationMethod,
    PrayerOffsets? offsets,
    IqamaOffsets? iqamaOffsets,
    int? preAdhanMinutes,
    int? adhanMomentDurationSeconds,
  }) {
    return PrayerSettings(
      mosqueId: mosqueId ?? this.mosqueId,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      offsets: offsets ?? this.offsets,
      iqamaOffsets: iqamaOffsets ?? this.iqamaOffsets,
      preAdhanMinutes: preAdhanMinutes ?? this.preAdhanMinutes,
      adhanMomentDurationSeconds:
          adhanMomentDurationSeconds ?? this.adhanMomentDurationSeconds,
    );
  }

  @override
  List<Object?> get props => [
    mosqueId,
    calculationMethod,
    offsets,
    iqamaOffsets,
    preAdhanMinutes,
    adhanMomentDurationSeconds,
  ];
}

class PrayerCalculationMethodOption extends Equatable {
  final String key;
  final String label;

  const PrayerCalculationMethodOption({required this.key, required this.label});

  factory PrayerCalculationMethodOption.fromJson(Map<String, dynamic> json) {
    final key = json['key']?.toString() ?? '';
    return PrayerCalculationMethodOption(
      key: key,
      label: json['label']?.toString() ?? key,
    );
  }

  @override
  List<Object?> get props => [key, label];
}

class PrayerPreviewItem extends Equatable {
  final String prayer;
  final DateTime? baseTime;
  final int offset;
  final DateTime? adhanTime;
  final int iqamaOffset;
  final DateTime? iqamaTime;

  const PrayerPreviewItem({
    required this.prayer,
    this.baseTime,
    this.offset = 0,
    this.adhanTime,
    this.iqamaOffset = 0,
    this.iqamaTime,
  });

  factory PrayerPreviewItem.fromJson(Map<String, dynamic> json) {
    return PrayerPreviewItem(
      prayer: json['prayer']?.toString() ?? '',
      baseTime: DateTime.tryParse(json['baseTime']?.toString() ?? ''),
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      adhanTime: DateTime.tryParse(json['adhanTime']?.toString() ?? ''),
      iqamaOffset: (json['iqamaOffset'] as num?)?.toInt() ?? 0,
      iqamaTime: DateTime.tryParse(json['iqamaTime']?.toString() ?? ''),
    );
  }

  @override
  List<Object?> get props => [
    prayer,
    baseTime,
    offset,
    adhanTime,
    iqamaOffset,
    iqamaTime,
  ];
}

class PrayerSettingsPreview extends Equatable {
  final DateTime? date;
  final String timezone;
  final String calculationMethod;
  final List<PrayerCalculationMethodOption> methods;
  final List<PrayerPreviewItem> items;

  const PrayerSettingsPreview({
    this.date,
    this.timezone = '',
    this.calculationMethod = 'MuslimWorldLeague',
    this.methods = const [],
    this.items = const [],
  });

  factory PrayerSettingsPreview.fromJson(Map<String, dynamic> json) {
    final methods = json['methods'];
    final items = json['items'];
    return PrayerSettingsPreview(
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      timezone: json['timezone']?.toString() ?? '',
      calculationMethod:
          json['calculationMethod']?.toString() ?? 'MuslimWorldLeague',
      methods: methods is List
          ? methods
                .whereType<Map>()
                .map(
                  (item) => PrayerCalculationMethodOption.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((item) => item.key.isNotEmpty)
                .toList()
          : const [],
      items: items is List
          ? items
                .whereType<Map>()
                .map(
                  (item) => PrayerPreviewItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((item) => item.prayer.isNotEmpty)
                .toList()
          : const [],
    );
  }

  PrayerPreviewItem? itemFor(String prayer) {
    for (final item in items) {
      if (item.prayer == prayer) return item;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    date,
    timezone,
    calculationMethod,
    methods,
    items,
  ];
}
