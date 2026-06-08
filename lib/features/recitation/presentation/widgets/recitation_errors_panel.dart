import 'package:flutter/material.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';

import '../../data/models/tracked_verse.dart';

class RecitationErrorsPanel extends StatelessWidget {
  final List<TrackedVerse> trackedVerses;

  const RecitationErrorsPanel({super.key, required this.trackedVerses});

  @override
  Widget build(BuildContext context) {
    final errors =
        trackedVerses
            .where((verse) => verse.status == TrackedVerseStatus.incorrect)
            .toList()
          ..sort((a, b) {
            final page = a.pageNumber.compareTo(b.pageNumber);
            if (page != 0) return page;
            final surah = a.surahNumber.compareTo(b.surahNumber);
            return surah != 0 ? surah : a.verseNumber.compareTo(b.verseNumber);
          });

    return Container(
      constraints: const BoxConstraints(maxHeight: 210),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8D2C5)),
      ),
      child: errors.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'لا توجد أخطاء مسجلة في الجلسة الحالية.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF66716C)),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(12),
              itemCount: errors.length,
              separatorBuilder: (_, _) => const Divider(height: 18),
              itemBuilder: (context, index) {
                final error = errors[index];
                return _ErrorEntry(error: error);
              },
            ),
    );
  }
}

class _ErrorEntry extends StatelessWidget {
  final TrackedVerse error;

  const _ErrorEntry({required this.error});

  @override
  Widget build(BuildContext context) {
    final surahName = getSurahNameArabic(error.surahNumber);
    final correction = getVerse(error.surahNumber, error.verseNumber);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$surahName - الآية ${error.verseNumber}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text('الخطأ: تم رصد خطأ في التلاوة.'),
        const SizedBox(height: 4),
        Text(
          'التصحيح: $correction',
          style: QuranTextStyles.hafsStyle(fontSize: 18),
        ),
      ],
    );
  }
}
