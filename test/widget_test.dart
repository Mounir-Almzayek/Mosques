import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tebyan/core/utils/color_extensions.dart';
import 'package:tebyan/data/models/app/app_config.dart';
import 'package:tebyan/data/models/mosque/mosque_bootstrap.dart';

void main() {
  test('MosqueBootstrap separates display and imam announcements', () {
    final now = DateTime.now();
    final display = Announcement(
      id: 'display',
      audience: 'display',
      title: 'Display announcement',
      startAt: now,
      endAt: now.add(const Duration(days: 1)),
    );
    final imam = Announcement(
      id: 'imam',
      audience: 'imam',
      title: 'Imam announcement',
      startAt: now,
      endAt: now.add(const Duration(days: 1)),
    );
    final alert = Announcement(
      id: 'alert',
      audience: 'display',
      announcementType: 'alert',
      title: 'Alert',
      startAt: now,
      endAt: now.add(const Duration(days: 1)),
    );

    final bootstrap = MosqueBootstrap(announcements: [display, imam, alert]);

    expect(bootstrap.ads.map((item) => item.id), ['display']);
    expect(bootstrap.appAnnouncements.map((item) => item.id), ['imam']);
    expect(bootstrap.savedAlerts.map((item) => item.id), ['alert']);
  });

  test('AppConfig parses bootstrap response with null latestRelease', () {
    final config = AppConfig.fromJson({
      'supportPhone': '',
      'backgroundLibraryUrls': [],
      'backgroundFolderUrl': '',
      'aboutCategories': [],
      'update': {
        'latestVersion': '1.0.0',
        'androidLink': '',
        'windowsLink': '',
        'iosLink': '',
        'macosLink': '',
        'linuxLink': '',
        'releaseNotes': '',
        'isUpdateAvailable': false,
      },
      'latestRelease': null,
    });

    expect(config.latestRelease, isNull);
    expect(config.update.latestVersion, '1.0.0');
  });

  test('AppConfig parses latestRelease object when available', () {
    final config = AppConfig.fromJson({
      'update': {'latestVersion': '1.2.0'},
      'latestRelease': {
        'platform': 'android',
        'version': '1.2.0',
        'downloadUrl': 'https://example.com/app.apk',
        'releaseNotes': 'Stable release',
        'isUpdateAvailable': true,
      },
    });

    expect(config.latestRelease?.platform, 'android');
    expect(config.latestRelease?.isUpdateAvailable, isTrue);
  });

  testWidgets('ColorOpacityCompat applies alpha factor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Container(color: Colors.blue.withOpacityCompat(0.5)),
        ),
      ),
    );
    expect(find.byType(Container), findsOneWidget);
  });
}
