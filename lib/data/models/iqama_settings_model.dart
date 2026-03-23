import 'package:equatable/equatable.dart';

class IqamaSettingsModel extends Equatable {
  final int fajrOffset;
  final int dhuhrOffset;
  final int asrOffset;
  final int maghribOffset;
  final int ishaOffset;
  final int jummahOffset;

  const IqamaSettingsModel({
    required this.fajrOffset,
    required this.dhuhrOffset,
    required this.asrOffset,
    required this.maghribOffset,
    required this.ishaOffset,
    this.jummahOffset = 30,
  });

  factory IqamaSettingsModel.fromMap(Map<String, dynamic> map) {
    return IqamaSettingsModel(
      fajrOffset: map['fajr'] ?? 20,
      dhuhrOffset: map['dhuhr'] ?? 15,
      asrOffset: map['asr'] ?? 15,
      maghribOffset: map['maghrib'] ?? 10,
      ishaOffset: map['isha'] ?? 15,
      jummahOffset: map['jummah'] ?? 30,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fajr': fajrOffset,
      'dhuhr': dhuhrOffset,
      'asr': asrOffset,
      'maghrib': maghribOffset,
      'isha': ishaOffset,
      'jummah': jummahOffset,
    };
  }

  IqamaSettingsModel copyWith({
    int? fajrOffset,
    int? dhuhrOffset,
    int? asrOffset,
    int? maghribOffset,
    int? ishaOffset,
    int? jummahOffset,
  }) {
    return IqamaSettingsModel(
      fajrOffset: fajrOffset ?? this.fajrOffset,
      dhuhrOffset: dhuhrOffset ?? this.dhuhrOffset,
      asrOffset: asrOffset ?? this.asrOffset,
      maghribOffset: maghribOffset ?? this.maghribOffset,
      ishaOffset: ishaOffset ?? this.ishaOffset,
      jummahOffset: jummahOffset ?? this.jummahOffset,
    );
  }

  @override
  List<Object?> get props => [
        fajrOffset,
        dhuhrOffset,
        asrOffset,
        maghribOffset,
        ishaOffset,
        jummahOffset,
      ];
}
