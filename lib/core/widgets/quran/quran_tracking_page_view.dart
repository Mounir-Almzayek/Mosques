// GetPage is not exported by qcf_quran_lite, but the package's page widget
// needs the same QuranPage objects it builds internally.
// ignore_for_file: implementation_imports

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';
import 'package:qcf_quran_lite/src/services/get_page.dart';
import 'package:qcf_quran_lite/src/widgets/bsmallah_widget.dart';
import 'package:qcf_quran_lite/src/widgets/surah_header_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'tracked_verse.dart';

class QuranTrackingPageView extends StatefulWidget {
  final int currentPage;
  final TrackedVerse? highlightedVerse;
  final ValueChanged<int> onPageSelected;

  const QuranTrackingPageView({
    super.key,
    required this.currentPage,
    this.highlightedVerse,
    required this.onPageSelected,
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
        color: verse.status == TrackedVerseStatus.incorrect
            ? Colors.redAccent
            : Colors.lightGreen,
      ),
    ];
  }

  double _pageHeaderAllowance(QuranPage page) {
    if (page.pageNumber <= 2 || page.numberOfNewSurahs == 0) return 0;
    final startsTawbah = page.ayahs.any(
      (ayah) => ayah.surahNumber == 9 && ayah.ayahNumber == 1,
    );
    return page.numberOfNewSurahs *
        (startsTawbah ? _tawbahHeaderAllowance : _surahHeaderAllowance);
  }

  double _ayahFontSize(QuranPage page, double pageHeight) {
    if (page.pageNumber <= 2) return QuranTextStyles.hafsStyle().fontSize!;
    final textHeight = pageHeight - _pageHeaderAllowance(page);
    return (textHeight / _standardMushafLines) * _fontSizeToLineHeight;
  }

  Widget _buildSurahHeader(BuildContext context, int surahNumber) {
    return SizedBox(
      height: surahNumber == 9
          ? _tawbahHeaderAllowance
          : _surahHeaderAllowance - 32,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
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
                builder: (context, constraints) {
                  final pageWidth = constraints.maxWidth;
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
                        key: PageStorageKey(
                          'recitation_page_${page.pageNumber}',
                        ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF2EBDD),
            border: Border.all(color: const Color(0xFF806B3E)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            width: medallionWidth,
            height: 42,
            child: Center(
              child: Text(
                pageLabel,
                style: QuranTextStyles.hafsStyle(
                  color: const Color(0xFF806B3E),
                  fontSize: 24,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
