import 'package:equatable/equatable.dart';

import '../../../data/models/mosque_model.dart';

import '../../../core/enums/app_language.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

// ——— General ———

class SettingsMosqueNameChanged extends SettingsEvent {
  final String name;

  const SettingsMosqueNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class SettingsMosqueCityChanged extends SettingsEvent {
  final String city;

  const SettingsMosqueCityChanged(this.city);

  @override
  List<Object?> get props => [city];
}

class SettingsPrayerCalculationMethodChanged extends SettingsEvent {
  final String calculationMethod;

  const SettingsPrayerCalculationMethodChanged(this.calculationMethod);

  @override
  List<Object?> get props => [calculationMethod];
}

class SettingsMosqueLanguageChanged extends SettingsEvent {
  final AppLanguage language;

  const SettingsMosqueLanguageChanged(this.language);

  @override
  List<Object?> get props => [language];
}

class SettingsMosqueCoordinatesChanged extends SettingsEvent {
  final double latitude;
  final double longitude;

  const SettingsMosqueCoordinatesChanged({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class SaveGeneralSettingsRequested extends SettingsEvent {
  const SaveGeneralSettingsRequested();
}

// ——— Design ———

class SettingsDesignBackgroundValueChanged extends SettingsEvent {
  final String backgroundValue;

  const SettingsDesignBackgroundValueChanged(this.backgroundValue);

  @override
  List<Object?> get props => [backgroundValue];
}

class SettingsDesignPrimaryColorChanged extends SettingsEvent {
  final String primaryColor;

  const SettingsDesignPrimaryColorChanged(this.primaryColor);

  @override
  List<Object?> get props => [primaryColor];
}

class SettingsDesignSecondaryColorChanged extends SettingsEvent {
  final String secondaryColor;

  const SettingsDesignSecondaryColorChanged(this.secondaryColor);

  @override
  List<Object?> get props => [secondaryColor];
}

class SettingsDesignPrayerOverlayChanged extends SettingsEvent {
  final String prayerOverlayColor;

  const SettingsDesignPrayerOverlayChanged(this.prayerOverlayColor);

  @override
  List<Object?> get props => [prayerOverlayColor];
}

class SettingsDesignBaseFontSizeChanged extends SettingsEvent {
  final double baseFontSize;

  const SettingsDesignBaseFontSizeChanged(this.baseFontSize);

  @override
  List<Object?> get props => [baseFontSize];
}

class SaveDesignSettingsRequested extends SettingsEvent {
  const SaveDesignSettingsRequested();
}

// ——— Iqama ———

class SettingsIqamaFajrOffsetChanged extends SettingsEvent {
  final int offset;

  const SettingsIqamaFajrOffsetChanged(this.offset);

  @override
  List<Object?> get props => [offset];
}

class SettingsIqamaDhuhrOffsetChanged extends SettingsEvent {
  final int offset;

  const SettingsIqamaDhuhrOffsetChanged(this.offset);

  @override
  List<Object?> get props => [offset];
}

class SettingsIqamaAsrOffsetChanged extends SettingsEvent {
  final int offset;

  const SettingsIqamaAsrOffsetChanged(this.offset);

  @override
  List<Object?> get props => [offset];
}

class SettingsIqamaMaghribOffsetChanged extends SettingsEvent {
  final int offset;

  const SettingsIqamaMaghribOffsetChanged(this.offset);

  @override
  List<Object?> get props => [offset];
}

class SettingsIqamaIshaOffsetChanged extends SettingsEvent {
  final int offset;

  const SettingsIqamaIshaOffsetChanged(this.offset);

  @override
  List<Object?> get props => [offset];
}

class SettingsIqamaJummahOffsetChanged extends SettingsEvent {
  final int offset;

  const SettingsIqamaJummahOffsetChanged(this.offset);

  @override
  List<Object?> get props => [offset];
}

class SaveIqamaSettingsRequested extends SettingsEvent {
  const SaveIqamaSettingsRequested();
}

// ——— نصوص العرض (أحاديث، آيات، أدعية، أذكار) ———

class SettingsMosqueTextAdded extends SettingsEvent {
  final MosqueTextListKind kind;
  final MosqueTextEntryModel item;

  const SettingsMosqueTextAdded(this.kind, this.item);

  @override
  List<Object?> get props => [kind, item];
}

class SettingsMosqueTextUpdated extends SettingsEvent {
  final MosqueTextListKind kind;
  final MosqueTextEntryModel item;

  const SettingsMosqueTextUpdated(this.kind, this.item);

  @override
  List<Object?> get props => [kind, item];
}

class SettingsMosqueTextRemoved extends SettingsEvent {
  final MosqueTextListKind kind;
  final String itemId;

  const SettingsMosqueTextRemoved(this.kind, this.itemId);

  @override
  List<Object?> get props => [kind, itemId];
}

class SaveMosqueTextListRequested extends SettingsEvent {
  final MosqueTextListKind kind;

  const SaveMosqueTextListRequested(this.kind);
}

// ——— Announcements ———

class SettingsAnnouncementAdded extends SettingsEvent {
  final AnnouncementModel announcement;

  const SettingsAnnouncementAdded(this.announcement);

  @override
  List<Object?> get props => [announcement];
}

class SettingsAnnouncementUpdated extends SettingsEvent {
  final AnnouncementModel announcement;

  const SettingsAnnouncementUpdated(this.announcement);

  @override
  List<Object?> get props => [announcement];
}

class SettingsAnnouncementRemoved extends SettingsEvent {
  final String announcementId;

  const SettingsAnnouncementRemoved(this.announcementId);

  @override
  List<Object?> get props => [announcementId];
}

class SaveAnnouncementsRequested extends SettingsEvent {
  const SaveAnnouncementsRequested();
}
