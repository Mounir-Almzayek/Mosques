import 'package:flutter/material.dart';

import '../../../../data/models/mosque/imam_tracking_session_model.dart';
import '../../../recitation/data/models/tracked_verse.dart';
import '../../../recitation/presentation/widgets/quran_tracking_page_view.dart';

class ImamTrackingLayer extends StatefulWidget {
  final ImamTrackingSessionModel session;
  final Color primaryColor;
  final Color backgroundColor;
  final ValueChanged<int> onPageSelected;

  const ImamTrackingLayer({
    super.key,
    required this.session,
    required this.primaryColor,
    required this.backgroundColor,
    required this.onPageSelected,
  });

  @override
  State<ImamTrackingLayer> createState() => _ImamTrackingLayerState();
}

class _ImamTrackingLayerState extends State<ImamTrackingLayer> {
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.session.currentPage;
  }

  @override
  void didUpdateWidget(covariant ImamTrackingLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.session.currentPage != oldWidget.session.currentPage) {
      _currentPage = widget.session.currentPage;
    }
  }

  void _onPageSelected(int pageNumber) {
    if (pageNumber == _currentPage) return;
    setState(() => _currentPage = pageNumber);
    widget.onPageSelected(pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    final trackedVerses = widget.session.trackedVerses
        .map(
          (verse) => TrackedVerse(
            surahNumber: verse.surahNumber,
            verseNumber: verse.verseNumber,
            pageNumber: verse.pageNumber,
            status: verse.isIncorrect
                ? TrackedVerseStatus.incorrect
                : TrackedVerseStatus.read,
          ),
        )
        .toList(growable: false);
    final highlightedVerse = widget.session.highlightedVerse;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.alphaBlend(
                Colors.white.withValues(alpha: 0.04),
                widget.backgroundColor,
              ),
              widget.backgroundColor,
              Color.alphaBlend(
                Colors.black.withValues(alpha: 0.10),
                widget.backgroundColor,
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'تتبع قراءة الإمام',
                          style: TextStyle(
                            color: widget.primaryColor,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: widget.primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: widget.primaryColor.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          'الصفحة $_currentPage من 604',
                          style: TextStyle(
                            color: widget.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: QuranTrackingPageView(
                      currentPage: _currentPage,
                      highlightedVerse: highlightedVerse == null
                          ? null
                          : TrackedVerse(
                              surahNumber: highlightedVerse.surahNumber,
                              verseNumber: highlightedVerse.verseNumber,
                              pageNumber: highlightedVerse.pageNumber,
                              status: TrackedVerseStatus.read,
                            ),
                      trackedVerses: trackedVerses,
                      onPageSelected: _onPageSelected,
                      onVerseRead: (_, _) {},
                      onVerseIncorrect: (_, _) {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
