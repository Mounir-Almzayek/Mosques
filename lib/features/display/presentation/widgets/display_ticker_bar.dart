import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../data/models/announcement_model.dart';
import '../../../../data/models/mosque_model.dart';
import '../../../../data/models/ticker_segment.dart';
import 'ticker_item_widget.dart';
import 'ticker_side_label_widget.dart';

/// Horizontal auto-scrolling ticker bar for announcements at the bottom
/// of the display screen.
class DisplayTickerBar extends StatefulWidget {
  final MosqueModel mosque;
  final List<AnnouncementModel> platformAnnouncements;
  final Color primaryColor;
  final double fontSize;

  const DisplayTickerBar({
    super.key,
    required this.mosque,
    required this.platformAnnouncements,
    required this.primaryColor,
    required this.fontSize,
  });

  @override
  State<DisplayTickerBar> createState() => _DisplayTickerBarState();
}

class _DisplayTickerBarState extends State<DisplayTickerBar> {
  static const _cream = Color(0xFFFFF8F0);
  
  // High-frequency tick for sub-pixel smoothness.
  static const _scrollTick = Duration(milliseconds: 12);

  List<TickerSegment> _segments = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _refreshContent();
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(covariant DisplayTickerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mosque != widget.mosque ||
        oldWidget.platformAnnouncements != widget.platformAnnouncements) {
      setState(_refreshContent);
      _startAutoScroll(); // Restart with new potentially faster speed
    }
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Auto-scroll
  // ---------------------------------------------------------------------------

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(_scrollTick, (_) {
      if (!mounted || !_scrollController.hasClients) return;
      final maxExtent = _scrollController.position.maxScrollExtent;
      if (maxExtent <= 0) return;

      // Base speed * configurable multiplier * time delta.
      final speedMultiplier = widget.mosque.designSettings.tickerSpeed;
      final pxPerTick = (30 * speedMultiplier) * (_scrollTick.inMilliseconds / 1000);
      final next = _scrollController.offset + pxPerTick;

      if (next >= maxExtent) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(next);
      }
    });
  }

  void _refreshContent() {
    _segments = TickerSegmentBuilder.build(
      mosque: widget.mosque,
      platform: widget.platformAnnouncements,
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

    final fontFamily = widget.mosque.designSettings.fontFamily;
    final numeralFormat = widget.mosque.designSettings.numeralFormat;
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
