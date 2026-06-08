// GetPage is not exported by qcf_quran_lite, but it is required to feed the
// package's own QuranSinglePageWidget in a continuous vertical list.
// ignore_for_file: implementation_imports

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';
import 'package:qcf_quran_lite/src/services/get_page.dart';
import 'package:qcf_quran_lite/src/widgets/bsmallah_widget.dart';
import 'package:qcf_quran_lite/src/widgets/surah_header_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../data/models/tracked_verse.dart';

class QuranTrackingPageView extends StatefulWidget {
  final int currentPage;
  final TrackedVerse? highlightedVerse;
  final List<TrackedVerse> trackedVerses;
  final ValueChanged<int> onPageSelected;
  final void Function(int surahNumber, int verseNumber) onVerseRead;
  final void Function(int surahNumber, int verseNumber) onVerseIncorrect;

  const QuranTrackingPageView({
    super.key,
    required this.currentPage,
    this.highlightedVerse,
    required this.trackedVerses,
    required this.onPageSelected,
    required this.onVerseRead,
    required this.onVerseIncorrect,
  });

  @override
  State<QuranTrackingPageView> createState() => _QuranTrackingPageViewState();
}

class _QuranTrackingPageViewState extends State<QuranTrackingPageView> {
  static const _mushafPageAspectRatio = 17 / 24;
  static const _standardMushafLines = 15;
  static const _surahHeaderAllowance = 110.0;
  static const _tawbahHeaderAllowance = 80.0;
  static const _fontSizeToLineHeight = 0.72;

  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();
  late final PageController _pageController;
  late final List<QuranPage> _pages;
  late int _reportedPage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pages = (GetPage()..getQuran(totalPagesCount)).staticPages;
    _reportedPage = widget.currentPage;
    _positionsListener.itemPositions.addListener(_reportCurrentPage);
  }

  @override
  void didUpdateWidget(covariant QuranTrackingPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPage == oldWidget.currentPage ||
        widget.currentPage == _reportedPage) {
      return;
    }

    _reportedPage = widget.currentPage;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.isAttached) return;
      _scrollController.jumpTo(index: widget.currentPage - 1);
    });
  }

  @override
  void dispose() {
    _positionsListener.itemPositions.removeListener(_reportCurrentPage);
    _pageController.dispose();
    super.dispose();
  }

  void _reportCurrentPage() {
    final visibleItems = _positionsListener.itemPositions.value.where(
      (position) =>
          position.itemTrailingEdge > 0 && position.itemLeadingEdge < 1,
    );
    if (visibleItems.isEmpty) return;

    final mostVisible = visibleItems.reduce((current, candidate) {
      double visibleFraction(ItemPosition position) {
        final leading = position.itemLeadingEdge.clamp(0.0, 1.0);
        final trailing = position.itemTrailingEdge.clamp(0.0, 1.0);
        return trailing - leading;
      }

      return visibleFraction(candidate) > visibleFraction(current)
          ? candidate
          : current;
    });
    final pageNumber = mostVisible.index + 1;
    if (pageNumber == _reportedPage) return;

    _reportedPage = pageNumber;
    widget.onPageSelected(pageNumber);
  }

  List<HighlightVerse> _buildHighlights() {
    final verse = widget.highlightedVerse;
    if (verse == null) return const [];

    return [
      HighlightVerse(
        surah: verse.surahNumber,
        verseNumber: verse.verseNumber,
        page: verse.pageNumber,
        color: Colors.lightGreen,
      ),
    ];
  }

  double _pageHeaderAllowance(QuranPage page) {
    if (page.pageNumber <= 2 || page.numberOfNewSurahs == 0) return 0;

    final startsTawbah = page.ayahs.any(
      (ayah) => ayah.surahNumber == 9 && ayah.ayahNumber == 1,
    );
    final allowancePerSurah = startsTawbah
        ? _tawbahHeaderAllowance
        : _surahHeaderAllowance;
    return page.numberOfNewSurahs * allowancePerSurah;
  }

  double _ayahFontSize(QuranPage page, double pageHeight) {
    if (page.pageNumber <= 2) {
      return QuranTextStyles.hafsStyle().fontSize!;
    }

    final textHeight = pageHeight - _pageHeaderAllowance(page);
    final lineHeight = textHeight / _standardMushafLines;
    return lineHeight * _fontSizeToLineHeight;
  }

  Widget _buildSurahHeader(BuildContext context, int surahNumber) {
    final availableWidth = MediaQuery.sizeOf(context).width;

    return SizedBox(
      height: surahNumber == 9
          ? _tawbahHeaderAllowance
          : _surahHeaderAllowance - 32,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: SizedBox(
          width: availableWidth,
          child: SurahHeaderWidget(suraNumber: surahNumber),
        ),
      ),
    );
  }

  Widget _buildBasmallah(BuildContext context, int surahNumber) {
    return SizedBox(
      height: 32,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: BasmallahWidget(surahNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final highlights = _buildHighlights();

    return ScrollablePositionedList.builder(
      initialScrollIndex: widget.currentPage - 1,
      itemCount: _pages.length,
      itemScrollController: _scrollController,
      itemPositionsListener: _positionsListener,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        final page = _pages[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, pageConstraints) {
                  final pageWidth = pageConstraints.maxWidth;
                  final basePageHeight = pageWidth / _mushafPageAspectRatio;
                  final pageHeight =
                      basePageHeight + _pageHeaderAllowance(page);

                  return SizedBox(
                    height: pageHeight,
                    child: MediaQuery(
                      data: mediaQuery.copyWith(
                        size: Size(pageWidth, pageHeight),
                      ),
                      child: QuranSinglePageWidget(
                        key: PageStorageKey('page_${page.pageNumber}'),
                        page: page,
                        pageIndex: page.pageNumber,
                        highlights: highlights,
                        pageController: _pageController,
                        pagePadding: EdgeInsets.zero,
                        surahHeaderBuilder: _buildSurahHeader,
                        basmallahBuilder: _buildBasmallah,
                        ayahStyle: TextStyle(
                          fontSize: _ayahFontSize(page, pageHeight),
                        ),
                        onTap: widget.onVerseRead,
                        onLongPress: widget.onVerseIncorrect,
                      ),
                    ),
                  );
                },
              ),
              _PageSeparator(pageNumber: page.pageNumber),
            ],
          ),
        );
      },
    );
  }
}

class _PageSeparator extends StatelessWidget {
  final int pageNumber;

  const _PageSeparator({required this.pageNumber});

  String _toArabicIndic(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((digit) => digits[int.parse(digit)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final pageLabel = _toArabicIndic(pageNumber);
    final medallionWidth = math.max(52.0, 28.0 + pageLabel.length * 15.0);
    const medallionHeight = 52.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ornamentColor = isDark
        ? const Color(0xFFC8B47A)
        : const Color(0xFF806B3E);
    final medallionColor = isDark
        ? const Color(0xFF263F36)
        : const Color(0xFFF2EBDD);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 34, 12, 20),
      child: SizedBox(
        height: medallionHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _MushafSeparatorPainter(
                  ornamentColor: ornamentColor,
                  medallionColor: medallionColor,
                  medallionSize: Size(medallionWidth, medallionHeight),
                ),
              ),
            ),
            ClipRect(
              child: SizedBox(
                width: medallionWidth - 14,
                height: medallionHeight - 14,
                child: Transform.translate(
                  offset: const Offset(0, -5),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      pageLabel,
                      textAlign: TextAlign.center,
                      style: QuranTextStyles.hafsStyle(
                        color: ornamentColor,
                        fontSize: 29,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MushafSeparatorPainter extends CustomPainter {
  final Color ornamentColor;
  final Color medallionColor;
  final Size medallionSize;

  const _MushafSeparatorPainter({
    required this.ornamentColor,
    required this.medallionColor,
    required this.medallionSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final linePaint = Paint()
      ..color = ornamentColor.withValues(alpha: 0.42)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final strongPaint = Paint()
      ..color = ornamentColor.withValues(alpha: 0.78)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const lineGap = 4.0;
    final medallionRadiusX = medallionSize.width / 2;
    final medallionRadiusY = medallionSize.height / 2;
    final leftEnd = center.dx - medallionRadiusX - 10;
    final rightStart = center.dx + medallionRadiusX + 10;

    for (final offset in [-lineGap / 2, lineGap / 2]) {
      canvas.drawLine(
        Offset(8, center.dy + offset),
        Offset(leftEnd, center.dy + offset),
        linePaint,
      );
      canvas.drawLine(
        Offset(rightStart, center.dy + offset),
        Offset(size.width - 8, center.dy + offset),
        linePaint,
      );
    }

    _drawDiamond(canvas, Offset(size.width * 0.25, center.dy), strongPaint);
    _drawDiamond(canvas, Offset(size.width * 0.75, center.dy), strongPaint);

    final rosette = Path();
    for (var index = 0; index < 16; index++) {
      final radiusFactor = index.isEven ? 1.0 : 0.84;
      final angle = -math.pi / 2 + index * math.pi / 8;
      final point = Offset(
        center.dx + math.cos(angle) * medallionRadiusX * radiusFactor,
        center.dy + math.sin(angle) * medallionRadiusY * radiusFactor,
      );
      if (index == 0) {
        rosette.moveTo(point.dx, point.dy);
      } else {
        rosette.lineTo(point.dx, point.dy);
      }
    }
    rosette.close();

    canvas.drawPath(
      rosette,
      Paint()
        ..color = medallionColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(rosette, strongPaint);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: medallionSize.width * 0.68,
        height: medallionSize.height * 0.68,
      ),
      Paint()
        ..color = ornamentColor.withValues(alpha: 0.48)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawDiamond(Canvas canvas, Offset center, Paint paint) {
    const width = 5.0;
    const height = 3.5;
    final path = Path()
      ..moveTo(center.dx, center.dy - height)
      ..lineTo(center.dx + width, center.dy)
      ..lineTo(center.dx, center.dy + height)
      ..lineTo(center.dx - width, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MushafSeparatorPainter oldDelegate) {
    return ornamentColor != oldDelegate.ornamentColor ||
        medallionColor != oldDelegate.medallionColor ||
        medallionSize != oldDelegate.medallionSize;
  }
}
