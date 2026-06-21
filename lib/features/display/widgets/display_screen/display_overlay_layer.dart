import 'package:flutter/material.dart';

import '../../../../core/enums/display/display_layer_kind.dart';
import '../../../../core/utils/box_fit_codec.dart';
import '../../../../core/utils/prayer_times_helper.dart';
import '../../../../data/models/mosque/mosque_bootstrap.dart';
import '../../bloc/display_state.dart';
import '../layers/alert_layer.dart';
import '../layers/iqama_adhan_layer.dart';
import '../layers/photo_studio_layer.dart';
import '../layers/recitation_layer.dart';

class DisplayOverlayLayer extends StatelessWidget {
  const DisplayOverlayLayer({
    super.key,
    required this.layer,
    required this.mosque,
    required this.design,
    required this.recitation,
    required this.photoStudioUrl,
    required this.now,
    required this.onExpired,
  });

  final DisplayLayerKind layer;
  final MosqueBootstrap mosque;
  final DisplaySettings design;
  final DisplayRecitationState? recitation;
  final String? photoStudioUrl;
  final DateTime now;
  final VoidCallback onExpired;

  @override
  Widget build(BuildContext context) {
    switch (layer) {
      case DisplayLayerKind.alert:
        return AlertLayer(
          alerts: mosque.savedAlerts,
          alertsFontSize: design.alertsFontSize,
          primaryColor: design.alertTextColorValue,
          backgroundColor: design.alertBackgroundColorValue,
          numeralFormat: design.numeralFormat,
          fontFamily: design.fontFamily,
          onExpired: onExpired,
        );
      case DisplayLayerKind.recitation:
        if (recitation != null) {
          return RecitationLayer(recitation: recitation!);
        }
        return const SizedBox.shrink();
      case DisplayLayerKind.photoStudio:
        return AlbumImageLayer(
          imageUrl: photoStudioUrl ?? '',
          backgroundColor: design.primaryColorValue,
          fit: boxFitFromName(design.publishedAlbumFit),
        );
      case DisplayLayerKind.iqamaAdhan:
        final helper = PrayerTimesHelper(mosque);
        final phase = helper.getPrayerDisplayPhase(
          now,
          preAdhanMinutes: mosque.prayerSettings.preAdhanMinutes,
          adhanMomentDurationSeconds:
              mosque.prayerSettings.adhanMomentDurationSeconds,
        );
        final remaining = phase.focusTime.difference(now);
        return IqamaAdhanLayer(
          phase: phase,
          remaining: remaining,
          designSettings: design,
          mosque: mosque,
          isFriday: now.weekday == DateTime.friday,
          countdownFontSize: design.countdownFontSize,
        );
      case DisplayLayerKind.religious:
        return const SizedBox.shrink();
      case DisplayLayerKind.prayerTimes:
        return const SizedBox.shrink();
    }
  }
}
