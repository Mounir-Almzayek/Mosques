import 'package:equatable/equatable.dart';

import '../../../../core/enums/app_numeral_format.dart';
import '../../../../core/enums/display_background_type.dart';
import '../../../../data/models/mosque/mosque_bootstrap.dart';

// ——— Enums ———

enum DesignColorField {
  primary,
  secondary,
  prayerOverlay,
  activeCard,
  activeCardText,
  inactiveCardText,
  countdownBackground,
  countdownText,
  alertBackground,
  alertText,
}

enum DesignFontSizeField {
  clock,
  mosqueInfo,
  prayers,
  announcements,
  religiousContent,
}

enum DisplayTimingField { preAdhanMinutes, adhanMomentDuration }

// ——— Events ———

sealed class DesignEvent extends Equatable {
  const DesignEvent();

  @override
  List<Object?> get props => [];
}

class LoadDesign extends DesignEvent {
  const LoadDesign();
}

/// Internal event emitted when the mosque stream pushes a new value.
class DesignMosqueUpdated extends DesignEvent {
  final MosqueBootstrap? mosque;

  const DesignMosqueUpdated(this.mosque);

  @override
  List<Object?> get props => [mosque];
}

class DesignBackgroundValueChanged extends DesignEvent {
  final String backgroundValue;

  const DesignBackgroundValueChanged(this.backgroundValue);

  @override
  List<Object?> get props => [backgroundValue];
}

class DesignBackgroundTypeChanged extends DesignEvent {
  final DisplayBackgroundType type;

  const DesignBackgroundTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

class DesignColorChanged extends DesignEvent {
  final DesignColorField field;
  final String color;

  const DesignColorChanged(this.field, this.color);

  @override
  List<Object?> get props => [field, color];
}

class DesignFontSizeChanged extends DesignEvent {
  final DesignFontSizeField field;
  final double fontSize;

  const DesignFontSizeChanged(this.field, this.fontSize);

  @override
  List<Object?> get props => [field, fontSize];
}

class DesignTickerSpeedChanged extends DesignEvent {
  final double speed;

  const DesignTickerSpeedChanged(this.speed);

  @override
  List<Object?> get props => [speed];
}

class DesignStripSpeedChanged extends DesignEvent {
  final double speed;

  const DesignStripSpeedChanged(this.speed);

  @override
  List<Object?> get props => [speed];
}

class DesignNumeralFormatChanged extends DesignEvent {
  final AppNumeralFormat format;

  const DesignNumeralFormatChanged(this.format);

  @override
  List<Object?> get props => [format];
}

class DesignFontFamilyChanged extends DesignEvent {
  final String fontFamily;

  const DesignFontFamilyChanged(this.fontFamily);

  @override
  List<Object?> get props => [fontFamily];
}

class DisplayTimingChanged extends DesignEvent {
  final DisplayTimingField field;
  final int value;

  const DisplayTimingChanged(this.field, this.value);

  @override
  List<Object?> get props => [field, value];
}

class PrayerCardScaleChanged extends DesignEvent {
  final double scale;

  const PrayerCardScaleChanged(this.scale);

  @override
  List<Object?> get props => [scale];
}

class BackgroundAlbumUrlAdded extends DesignEvent {
  final String url;

  const BackgroundAlbumUrlAdded(this.url);

  @override
  List<Object?> get props => [url];
}

class BackgroundAlbumUrlRemoved extends DesignEvent {
  final int index;

  const BackgroundAlbumUrlRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class BackgroundAlbumUrlsReordered extends DesignEvent {
  final List<String> urls;

  const BackgroundAlbumUrlsReordered(this.urls);

  @override
  List<Object?> get props => [urls];
}

class BackgroundCustomUrlChanged extends DesignEvent {
  final String url;

  const BackgroundCustomUrlChanged(this.url);

  @override
  List<Object?> get props => [url];
}

class SaveDesignRequested extends DesignEvent {
  const SaveDesignRequested();
}

class DiscardDesignChangesRequested extends DesignEvent {
  const DiscardDesignChangesRequested();
}
