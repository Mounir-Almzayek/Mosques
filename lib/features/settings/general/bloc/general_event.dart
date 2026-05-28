import 'package:equatable/equatable.dart';

import '../../../../core/enums/app_language.dart';
import '../../../../data/models/mosque/mosque_model.dart';

// ——— Enums ———

enum GeneralField { name, city, calculationMethod }

enum PrayerOffsetField { fajr, sunrise, dhuhr, asr, maghrib, isha }

// ——— Events ———

sealed class GeneralEvent extends Equatable {
  const GeneralEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneral extends GeneralEvent {
  const LoadGeneral();
}

class GeneralSettingChanged extends GeneralEvent {
  final GeneralField field;
  final Object value;

  const GeneralSettingChanged(this.field, this.value);

  @override
  List<Object?> get props => [field, value];
}

class LanguageChanged extends GeneralEvent {
  final AppLanguage language;

  const LanguageChanged(this.language);

  @override
  List<Object?> get props => [language];
}

class CoordinatesChanged extends GeneralEvent {
  final double latitude;
  final double longitude;

  const CoordinatesChanged({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class PrayerOffsetChanged extends GeneralEvent {
  final PrayerOffsetField prayer;
  final int offset;

  const PrayerOffsetChanged(this.prayer, this.offset);

  @override
  List<Object?> get props => [prayer, offset];
}

class SaveGeneralRequested extends GeneralEvent {
  const SaveGeneralRequested();
}

/// Internal event emitted when the mosque stream pushes a new value.
/// Not part of the public API; use [LoadGeneral] instead.
class GeneralMosqueUpdated extends GeneralEvent {
  final MosqueModel? mosque;

  const GeneralMosqueUpdated(this.mosque);

  @override
  List<Object?> get props => [mosque];
}
