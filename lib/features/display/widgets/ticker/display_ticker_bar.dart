import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../data/models/display/ticker_segment_builder.dart';
import '../../../../data/models/app/app_config.dart';
import '../../../../data/models/mosque/mosque_bootstrap.dart';
import '../../../../data/models/display/ticker_segment.dart';
import 'ticker_item_widget.dart';
import 'ticker_side_label_widget.dart';

/// Horizontal auto-scrolling ticker bar for announcements at the bottom
/// of the display screen.
class DisplayTickerBar extends StatefulWidget {
  final MosqueBootstrap mosque;
  final List<Announcement> platformAnnouncements;
  final AppConfig? appSettings;
  final String? currentVersion;
  final Color primaryColor;
  final double fontSize;

  const DisplayTickerBar({
    super.key,
    required this.mosque,
    required this.platformAnnouncements,
    this.appSettings,
    this.currentVersion,
    required this.primaryColor,
    required this.fontSize,
  });

  @override
  State<DisplayTickerBar> createState() => _DisplayTickerBarState();
}

class _DisplayTickerBarState extends State<DisplayTickerBar>
    with SingleTickerProviderStateMixin {
  static const _cream = Color(0xFFFFF8F0);

  // Base scroll speed in logical pixels per second (scaled by tickerSpeed).
  static const _basePxPerSecond = 30.0;

  List<TickerSegment> _segments = [];
  final ScrollController _scrollController = ScrollController();
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _refreshContent();
    // Drive scrolling from the vsync ticker (one callback per frame) so motion
    // stays in lockstep with the display refresh — no Timer drift or jank.
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant DisplayTickerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mosque != widget.mosque ||
        oldWidget.platformAnnouncements != widget.platformAnnouncements ||
        oldWidget.appSettings != widget.appSettings ||
        oldWidget.currentVersion != widget.currentVersion) {
      setState(_refreshContent);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Auto-scroll
  // ---------------------------------------------------------------------------

  void _onTick(Duration elapsed) {
    if (!_scrollController.hasClients) {
      _lastElapsed = elapsed;
      return;
    }
    final position = _scrollController.position;
    final maxExtent = position.maxScrollExtent;
    if (maxExtent <= 0) {
      _lastElapsed = elapsed;
      return;
    }

    // Advance by real elapsed time → constant velocity even if a frame drops.
    // Clamp the delta so a long pause (e.g. app resumed) can't cause a jump.
    final dt = ((elapsed - _lastElapsed).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _lastElapsed = elapsed;

    final speedMultiplier = widget.mosque.displaySettings.tickerSpeed;
    var next = _scrollController.offset + _basePxPerSecond * speedMultiplier * dt;

    // The content is rendered twice back-to-back, so one copy spans half the
    // total scrollable width. Wrapping by exactly one copy lands on visually
    // identical content — a seamless loop with no visible reset.
    final oneCopy = (maxExtent + position.viewportDimension) / 2;
    if (oneCopy >= position.viewportDimension && next >= oneCopy) {
      next -= oneCopy;
    } else if (next >= maxExtent) {
      next = 0;
    }
    _scrollController.jumpTo(next.clamp(0.0, maxExtent));
  }

  void _refreshContent() {
    _segments = TickerSegmentBuilder.build(
      mosque: widget.mosque,
      platform: widget.platformAnnouncements,
      appSettings: widget.appSettings,
      currentVersion: widget.currentVersion,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(0);
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_segments.isEmpty) return const SizedBox.shrink();

    final fontFamily = widget.mosque.displaySettings.fontFamily;
    final numeralFormat = widget.mosque.displaySettings.numeralFormat;
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode.toLowerCase().startsWith('ar');
    final dir = isArabic ? TextDirection.rtl : Directionality.of(context);

    final media = MediaQuery.sizeOf(context);
    final shortest = media.shortestSide;
    final barHeight = (shortest * 0.105).clamp(56.0, 92.0);
    final sidePanelW = (shortest * 0.09).clamp(80.0, 132.0);
    final qrSize = (barHeight * 0.52).clamp(36.0, 52.0);
    final fontSize = (widget.fontSize * 1.28).clamp(14.0, 28.0);
    final sideFontSize = (fontSize * 1.04).clamp(14.0, 26.0);
    final duplicated = [..._segments, ..._segments];

    return Container(
      height: barHeight,
      width: double.infinity,
      color: widget.primaryColor,
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          textDirection: dir,
          children: [
            SizedBox(
              width: sidePanelW,
              child: TickerSideLabelWidget(
                fontFamily: fontFamily,
                fontSize: sideFontSize,
                textColor: _cream,
              ),
            ),
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(vertical: 14),
              color: _cream.withValues(alpha: 0.36),
            ),
            Expanded(
              child: ClipRect(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: duplicated.length,
                  itemBuilder: (context, index) {
                    final item = duplicated[index];
                    return TickerItemWidget(
                      item: item,
                      fontSize: fontSize,
                      qrSize: qrSize,
                      fontFamily: fontFamily,
                      numeralFormat: numeralFormat,
                      textColor: _cream,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
