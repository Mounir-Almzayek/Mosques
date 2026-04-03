import '../../../core/enums/display/ticker_kind.dart';
import '../../../core/utils/version_helper.dart';
import '../app/app_settings_model.dart';
import '../mosque/announcement_model.dart';
import '../mosque/mosque_model.dart';
import 'ticker_segment.dart';

class TickerSegmentBuilder {
  TickerSegmentBuilder._();

  static List<TickerSegment> build({
    required MosqueModel mosque,
    required List<AnnouncementModel> platform,
    AppSettingsModel? appSettings,
    String? currentVersion,
  }) {
    final now = DateTime.now();

    final platformVisible = platform
        .where((a) => _isVisible(a, now))
        .map(
          (a) => TickerSegment(
            kind: TickerKind.platformAd,
            text: _marqueeText(a).trim(),
            qrData: a.qrCodeUrl?.trim(),
          ),
        )
        .where((seg) => seg.text.isNotEmpty)
        .toList();

    final mosqueVisible = mosque.announcements
        .where((a) => _isVisible(a, now))
        .map(
          (a) => TickerSegment(
            kind: TickerKind.mosqueAd,
            text: _marqueeText(a).trim(),
            qrData: a.qrCodeUrl?.trim(),
          ),
        )
        .where((seg) => seg.text.isNotEmpty)
        .toList();

    if (appSettings != null && currentVersion != null) {
      if (VersionHelper.isUpdateAvailable(
        currentVersion,
        appSettings.latestVersion,
      )) {
        if (appSettings.updateMessage.trim().isNotEmpty) {
          mosqueVisible.insert(
            0,
            TickerSegment(
              kind: TickerKind.appUpdate,
              text: appSettings.updateMessage.trim(),
            ),
          );
        }
      }
    }

    final out = <TickerSegment>[];
    final maxLen = platformVisible.length > mosqueVisible.length
        ? platformVisible.length
        : mosqueVisible.length;
    for (var i = 0; i < maxLen; i++) {
      if (mosqueVisible.length > i) out.add(mosqueVisible[i]);
      if (platformVisible.length > i) out.add(platformVisible[i]);
    }
    return out;
  }

  static bool _isVisible(AnnouncementModel a, DateTime now) {
    return a.isActive && !a.startDate.isAfter(now) && a.endDate.isAfter(now);
  }

  static String _marqueeText(AnnouncementModel a) {
    if (a.subtitle != null && a.subtitle!.trim().isNotEmpty) {
      return '${a.title} — ${a.subtitle!.trim()}';
    }
    return a.title;
  }
}

