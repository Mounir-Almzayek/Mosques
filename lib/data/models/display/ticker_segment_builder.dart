import '../../../core/utils/version_helper.dart';
import '../app/app_config.dart';
import '../mosque/mosque_bootstrap.dart';
import 'ticker_segment.dart';

class TickerSegmentBuilder {
  TickerSegmentBuilder._();

  static List<TickerSegment> build({
    required MosqueBootstrap mosque,
    required List<Announcement> platform,
    AppConfig? appSettings,
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

  static bool _isVisible(Announcement a, DateTime now) {
    return a.isActiveAt(now);
  }

  static String _marqueeText(Announcement a) {
    if (a.subtitle != null && a.subtitle!.trim().isNotEmpty) {
      return '${a.title} — ${a.subtitle!.trim()}';
    }
    return a.title;
  }
}

