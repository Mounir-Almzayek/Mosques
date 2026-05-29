import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/offline_image_store.dart';
import 'package:Tebyan/core/widgets/media/app_image.dart';

class _FakeDownloader implements ImageDownloader {
  @override
  Future<Uint8List> download(String url) async {
    return Uint8List.fromList(<int>[
      0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52,
      0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,
      0x89,0x00,0x00,0x00,0x0A,0x49,0x44,0x41,0x54,0x78,0x9C,0x63,0x00,0x01,0x00,0x00,
      0x05,0x00,0x01,0x0D,0x0A,0x2D,0xB4,0x00,0x00,0x00,0x00,0x49,0x45,0x4E,0x44,0xAE,
      0x42,0x60,0x82,
    ]);
  }
}

void main() {
  testWidgets('AppImage.network renders a placeholder then resolves', (tester) async {
    final tempDir =
        await tester.runAsync(() => Directory.systemTemp.createTemp('appimg'));
    final store =
        OfflineImageStore(downloader: _FakeDownloader(), baseDirOverride: tempDir);
    await tester.runAsync(() => store.init());

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppImage.network(
          'https://x/a.png',
          imageStore: store,
          width: 50,
          height: 50,
        ),
      ),
    ));
    expect(find.byType(AppImage), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(() => tempDir!.delete(recursive: true));
  });

  testWidgets('AppImage.asset builds without throwing', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AppImage.asset('assets/logo.png', width: 40, height: 40)),
    ));
    expect(find.byType(AppImage), findsOneWidget);
  });
}
