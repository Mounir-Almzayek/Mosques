import 'mosque_model.dart';

/// Kind of announcement in the horizontal ticker.
enum TickerKind { platformAd, mosqueAd }

/// A single segment to display in the ticker bar.
class TickerSegment {
  final TickerKind kind;
  final String text;
  final String? qrData;

  const TickerSegment({required this.kind, required this.text, this.qrData});
}

/// Builds the interleaved list of ticker segments from mosque and platform ads.
class TickerSegmentBuilder {
  TickerSegmentBuilder._();

  static List<TickerSegment> build({
    required MosqueModel mosque,
    required List<AnnouncementModel> platform,
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

    // Interleave: mosque first, then platform, round-robin.
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
