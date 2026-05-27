import 'package:equatable/equatable.dart';

import '../../../../data/models/mosque/mosque_model.dart';

import '../../../../core/enums/app_language.dart';
import '../../../../core/enums/app_numeral_format.dart';
import '../../../../core/enums/display_background_type.dart';

// ——— Enums for parameterized events ———

enum GeneralField { name, city, calculationMethod }

enum PrayerOffsetField { fajr, sunrise, dhuhr, asr, maghrib, isha }

enum DesignColorField {
  primary,
  secondary,
  prayerOverlay,
  activeCard,
  activeCardText,
  inactiveCardText,
}

enum DesignFontSizeField { clock, mosqueInfo, prayers, announcements, religiousContent, alerts, countdown }

enum DisplayTimingField {
  preAdhanMinutes,
  adhanMomentDuration,
  religiousContentWait,
  religiousContentDisplay,
}

enum IqamaField { fajr, dhuhr, asr, maghrib, isha, jummah }

// ——— Base ———

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

// ——— General ———

class GeneralSettingChanged extends SettingsEvent {
  final GeneralField field;
  final Object value;

  const GeneralSettingChanged(this.field, this.value);

  @override
  List<Object?> get props => [field, value];
}

class LanguageChanged extends SettingsEvent {
  final AppLanguage language;

  const LanguageChanged(this.language);

  @override
  List<Object?> get props => [language];
}

class CoordinatesChanged extends SettingsEvent {
  final double latitude;
  final double longitude;

  const CoordinatesChanged({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class PrayerOffsetChanged extends SettingsEvent {
  final PrayerOffsetField prayer;
  final int offset;

  const PrayerOffsetChanged(this.prayer, this.offset);

  @override
  List<Object?> get props => [prayer, offset];
}

class SaveGeneralSettingsRequested extends SettingsEvent {
  const SaveGeneralSettingsRequested();
}

// ——— Design ———

class DesignBackgroundValueChanged extends SettingsEvent {
  final String backgroundValue;

  const DesignBackgroundValueChanged(this.backgroundValue);

  @override
  List<Object?> get props => [backgroundValue];
}

class DesignBackgroundTypeChanged extends SettingsEvent {
  final DisplayBackgroundType type;

  const DesignBackgroundTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

class DesignColorChanged extends SettingsEvent {
  final DesignColorField field;
  final String color;

  const DesignColorChanged(this.field, this.color);

  @override
  List<Object?> get props => [field, color];
}

class DesignFontSizeChanged extends SettingsEvent {
  final DesignFontSizeField field;
  final double fontSize;

  const DesignFontSizeChanged(this.field, this.fontSize);

  @override
  List<Object?> get props => [field, fontSize];
}

class DesignTickerSpeedChanged extends SettingsEvent {
  final double speed;

  const DesignTickerSpeedChanged(this.speed);

  @override
  List<Object?> get props => [speed];
}

class DesignStripSpeedChanged extends SettingsEvent {
  final double speed;

  const DesignStripSpeedChanged(this.speed);

  @override
  List<Object?> get props => [speed];
}

class DesignNumeralFormatChanged extends SettingsEvent {
  final AppNumeralFormat format;

  const DesignNumeralFormatChanged(this.format);

  @override
  List<Object?> get props => [format];
}

class DesignFontFamilyChanged extends SettingsEvent {
  final String fontFamily;

  const DesignFontFamilyChanged(this.fontFamily);

  @override
  List<Object?> get props => [fontFamily];
}

class DisplayTimingChanged extends SettingsEvent {
  final DisplayTimingField field;
  final int value;

  const DisplayTimingChanged(this.field, this.value);

  @override
  List<Object?> get props => [field, value];
}

class BackgroundCustomUrlChanged extends SettingsEvent {
  final String url;

  const BackgroundCustomUrlChanged(this.url);

  @override
  List<Object?> get props => [url];
}

class PrayerCardScaleChanged extends SettingsEvent {
  final double scale;

  const PrayerCardScaleChanged(this.scale);

  @override
  List<Object?> get props => [scale];
}

class BackgroundAlbumUrlAdded extends SettingsEvent {
  final String url;

  const BackgroundAlbumUrlAdded(this.url);

  @override
  List<Object?> get props => [url];
}

class BackgroundAlbumUrlRemoved extends SettingsEvent {
  final int index;

  const BackgroundAlbumUrlRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class BackgroundAlbumUrlsReordered extends SettingsEvent {
  final List<String> urls;

  const BackgroundAlbumUrlsReordered(this.urls);

  @override
  List<Object?> get props => [urls];
}

class SaveDesignSettingsRequested extends SettingsEvent {
  const SaveDesignSettingsRequested();
}

// ——— Iqama ———

class IqamaOffsetChanged extends SettingsEvent {
  final IqamaField prayer;
  final int offset;

  const IqamaOffsetChanged(this.prayer, this.offset);

  @override
  List<Object?> get props => [prayer, offset];
}

class SaveIqamaSettingsRequested extends SettingsEvent {
  const SaveIqamaSettingsRequested();
}

// ——— Mosque Text Lists ———

class MosqueTextAdded extends SettingsEvent {
  final MosqueTextListKind kind;
  final MosqueTextEntryModel item;

  const MosqueTextAdded(this.kind, this.item);

  @override
  List<Object?> get props => [kind, item];
}

class MosqueTextUpdated extends SettingsEvent {
  final MosqueTextListKind kind;
  final MosqueTextEntryModel item;

  const MosqueTextUpdated(this.kind, this.item);

  @override
  List<Object?> get props => [kind, item];
}

class MosqueTextRemoved extends SettingsEvent {
  final MosqueTextListKind kind;
  final String itemId;

  const MosqueTextRemoved(this.kind, this.itemId);

  @override
  List<Object?> get props => [kind, itemId];
}

class SaveMosqueTextListRequested extends SettingsEvent {
  final MosqueTextListKind kind;

  const SaveMosqueTextListRequested(this.kind);
}

// ——— Announcements ———

class AnnouncementAdded extends SettingsEvent {
  final AnnouncementModel announcement;

  const AnnouncementAdded(this.announcement);

  @override
  List<Object?> get props => [announcement];
}

class AnnouncementUpdated extends SettingsEvent {
  final AnnouncementModel announcement;

  const AnnouncementUpdated(this.announcement);

  @override
  List<Object?> get props => [announcement];
}

class AnnouncementRemoved extends SettingsEvent {
  final String announcementId;

  const AnnouncementRemoved(this.announcementId);

  @override
  List<Object?> get props => [announcementId];
}

class SaveAnnouncementsRequested extends SettingsEvent {
  const SaveAnnouncementsRequested();
}

// ——— Instant Alerts ———

class AlertAdded extends SettingsEvent {
  final AnnouncementModel alert;

  const AlertAdded(this.alert);

  @override
  List<Object?> get props => [alert];
}

class AlertRemoved extends SettingsEvent {
  final String alertId;

  const AlertRemoved(this.alertId);

  @override
  List<Object?> get props => [alertId];
}

class AlertPublished extends SettingsEvent {
  final String alertId;
  final int durationSeconds;
  const AlertPublished(this.alertId, this.durationSeconds);
  @override
  List<Object?> get props => [alertId, durationSeconds];
}

class AlertUnpublished extends SettingsEvent {
  final String alertId;
  const AlertUnpublished(this.alertId);
  @override
  List<Object?> get props => [alertId];
}

class AlertUpdated extends SettingsEvent {
  final AnnouncementModel alert;
  const AlertUpdated(this.alert);
  @override
  List<Object?> get props => [alert];
}

class AllAlertsDeleted extends SettingsEvent {
  const AllAlertsDeleted();
}

class SaveAlertsRequested extends SettingsEvent {
  const SaveAlertsRequested();
}

// ——— Album ———

class AlbumImageAdded extends SettingsEvent {
  final String url;
  const AlbumImageAdded(this.url);
  @override
  List<Object?> get props => [url];
}

class AlbumImageRemoved extends SettingsEvent {
  final String url;
  const AlbumImageRemoved(this.url);
  @override
  List<Object?> get props => [url];
}

class AlbumImagePublished extends SettingsEvent {
  final String url;
  final int durationSeconds;
  const AlbumImagePublished(this.url, this.durationSeconds);
  @override
  List<Object?> get props => [url, durationSeconds];
}

class AlbumImageUnpublished extends SettingsEvent {
  const AlbumImageUnpublished();
}

class SaveAlbumRequested extends SettingsEvent {
  const SaveAlbumRequested();
}
