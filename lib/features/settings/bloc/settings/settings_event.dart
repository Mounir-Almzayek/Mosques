import 'package:equatable/equatable.dart';

import '../../../../data/models/mosque_model.dart';

import '../../../../core/enums/app_language.dart';
import '../../../../core/enums/app_numeral_format.dart';
import '../../../../core/enums/display_background_type.dart';

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

class SettingsPrayerOffsetFajrChanged extends SettingsEvent {
  final int offset;
  const SettingsPrayerOffsetFajrChanged(this.offset);
  @override
  List<Object?> get props => [offset];
}

class SettingsPrayerOffsetSunriseChanged extends SettingsEvent {
  final int offset;
  const SettingsPrayerOffsetSunriseChanged(this.offset);
  @override
  List<Object?> get props => [offset];
}

class SettingsPrayerOffsetDhuhrChanged extends SettingsEvent {
  final int offset;
  const SettingsPrayerOffsetDhuhrChanged(this.offset);
  @override
  List<Object?> get props => [offset];
}

class SettingsPrayerOffsetAsrChanged extends SettingsEvent {
  final int offset;
  const SettingsPrayerOffsetAsrChanged(this.offset);
  @override
  List<Object?> get props => [offset];
}

class SettingsPrayerOffsetMaghribChanged extends SettingsEvent {
  final int offset;
  const SettingsPrayerOffsetMaghribChanged(this.offset);
  @override
  List<Object?> get props => [offset];
}

class SettingsPrayerOffsetIshaChanged extends SettingsEvent {
  final int offset;
  const SettingsPrayerOffsetIshaChanged(this.offset);
  @override
  List<Object?> get props => [offset];
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

class SettingsDesignBackgroundTypeChanged extends SettingsEvent {
  final DisplayBackgroundType type;

  const SettingsDesignBackgroundTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
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

class SettingsDesignActiveCardColorChanged extends SettingsEvent {
  final String color;
  const SettingsDesignActiveCardColorChanged(this.color);
  @override
  List<Object?> get props => [color];
}

class SettingsDesignActiveCardTextColorChanged extends SettingsEvent {
  final String color;
  const SettingsDesignActiveCardTextColorChanged(this.color);
  @override
  List<Object?> get props => [color];
}

class SettingsDesignInactiveCardTextColorChanged extends SettingsEvent {
  final String color;
  const SettingsDesignInactiveCardTextColorChanged(this.color);
  @override
  List<Object?> get props => [color];
}

class SettingsDesignClockFontSizeChanged extends SettingsEvent {
  final double fontSize;
  const SettingsDesignClockFontSizeChanged(this.fontSize);
  @override
  List<Object?> get props => [fontSize];
}

class SettingsDesignMosqueInfoFontSizeChanged extends SettingsEvent {
  final double fontSize;
  const SettingsDesignMosqueInfoFontSizeChanged(this.fontSize);
  @override
  List<Object?> get props => [fontSize];
}

class SettingsDesignPrayersFontSizeChanged extends SettingsEvent {
  final double fontSize;
  const SettingsDesignPrayersFontSizeChanged(this.fontSize);
  @override
  List<Object?> get props => [fontSize];
}

class SettingsDesignAnnouncementsFontSizeChanged extends SettingsEvent {
  final double fontSize;
  const SettingsDesignAnnouncementsFontSizeChanged(this.fontSize);
  @override
  List<Object?> get props => [fontSize];
}

class SettingsDesignContentFontSizeChanged extends SettingsEvent {
  final double fontSize;
  const SettingsDesignContentFontSizeChanged(this.fontSize);
  @override
  List<Object?> get props => [fontSize];
}

class SettingsDesignTickerSpeedChanged extends SettingsEvent {
  final double speed;

  const SettingsDesignTickerSpeedChanged(this.speed);

  @override
  List<Object?> get props => [speed];
}

class SettingsDesignNumeralFormatChanged extends SettingsEvent {
  final AppNumeralFormat format;

  const SettingsDesignNumeralFormatChanged(this.format);

  @override
  List<Object?> get props => [format];
}

class SettingsDesignFontFamilyChanged extends SettingsEvent {
  final String fontFamily;

  const SettingsDesignFontFamilyChanged(this.fontFamily);

  @override
  List<Object?> get props => [fontFamily];
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

// ——— Instant Announcements (Alerts) ———

class SettingsAlertAdded extends SettingsEvent {
  final AnnouncementModel alert;
  const SettingsAlertAdded(this.alert);
  @override
  List<Object?> get props => [alert];
}

class SettingsAlertRemoved extends SettingsEvent {
  final String alertId;
  const SettingsAlertRemoved(this.alertId);
  @override
  List<Object?> get props => [alertId];
}

class SettingsAlertsCleared extends SettingsEvent {
  const SettingsAlertsCleared();
}

class SaveAlertsRequested extends SettingsEvent {
  const SaveAlertsRequested();
}
