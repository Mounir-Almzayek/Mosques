import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../../data/models/announcement_model.dart';
import '../../../../data/models/mosque_model.dart';
import '../../../../data/models/ticker_segment.dart';

/// Horizontal auto-scrolling ticker bar for announcements at the bottom
/// of the display screen.
class DisplayTickerBar extends StatefulWidget {
  final MosqueModel mosque;
  final List<AnnouncementModel> platformAnnouncements;
  final Color primaryColor;
  final double baseFontSize;

  const DisplayTickerBar({
    super.key,
    required this.mosque,
    required this.platformAnnouncements,
    required this.primaryColor,
    required this.baseFontSize,
  });

  @override
  State<DisplayTickerBar> createState() => _DisplayTickerBarState();
}

class _DisplayTickerBarState extends State<DisplayTickerBar> {
  static const _cream = Color(0xFFFFF8F0);
  static const _itemGap = 26.0;
  
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
  // Build helpers
  // ---------------------------------------------------------------------------

  String _sideLabel(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode.toLowerCase().startsWith('ar')) {
      return 'إعلانات';
    }
    return 'Ads';
  }

  bool _hasQr(TickerSegment item) => (item.qrData ?? '').trim().isNotEmpty;

  Widget _buildTickerItem(
    S s,
    TickerSegment item,
    double fontSize, {
    required double qrSize,
  }) {
    final numeralFormat = widget.mosque.designSettings.numeralFormat;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          ' ${item.text.formatNumerals(numeralFormat)}',
          style: TextStyle(
            color: _cream,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
            height: 1.34,
          ),
        ),
        if (_hasQr(item)) ...[
          const SizedBox(width: 12),
          Container(
            width: qrSize,
            height: qrSize,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: QrImageView(
              data: item.qrData!.trim(),
              version: QrVersions.auto,
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Text(
          '      ۞      ',
          style: TextStyle(
            color: _cream,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
            height: 1.34,
          ),
        ),
        const SizedBox(width: _itemGap),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    if (_segments.isEmpty) return const SizedBox.shrink();

    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode.toLowerCase().startsWith('ar');
    final dir = isArabic ? TextDirection.rtl : Directionality.of(context);
    final media = MediaQuery.sizeOf(context);
    final shortest = media.shortestSide;
    final barHeight = (shortest * 0.105).clamp(56.0, 92.0);
    final sidePanelW = (shortest * 0.09).clamp(80.0, 132.0);
    final qrSize = (barHeight * 0.52).clamp(36.0, 52.0);
    final fontSize = (widget.baseFontSize * 1.28).clamp(14.0, 28.0);
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
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _sideLabel(context),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(
                        color: _cream,
                        fontWeight: FontWeight.w900,
                        fontSize: sideFontSize,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
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
                    return _buildTickerItem(s, item, fontSize, qrSize: qrSize);
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
