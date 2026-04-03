import 'package:equatable/equatable.dart';

/// Individual minute adjustments for calculated prayer times.
class PrayerOffsetsModel extends Equatable {
  final int fajr;
  final int sunrise;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;

  const PrayerOffsetsModel({
    this.fajr = 0,
    this.sunrise = 0,
    this.dhuhr = 0,
    this.asr = 0,
    this.maghrib = 0,
    this.isha = 0,
  });

  factory PrayerOffsetsModel.fromMap(Map<String, dynamic> map) {
    return PrayerOffsetsModel(
      fajr: (map['fajr'] ?? 0).toInt(),
      sunrise: (map['sunrise'] ?? 0).toInt(),
      dhuhr: (map['dhuhr'] ?? 0).toInt(),
      asr: (map['asr'] ?? 0).toInt(),
      maghrib: (map['maghrib'] ?? 0).toInt(),
      isha: (map['isha'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    };
  }

  PrayerOffsetsModel copyWith({
    int? fajr,
    int? sunrise,
    int? dhuhr,
    int? asr,
    int? maghrib,
    int? isha,
  }) {
    return PrayerOffsetsModel(
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
