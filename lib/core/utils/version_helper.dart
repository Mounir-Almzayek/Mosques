import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../data/models/app/app_update_model.dart';

class VersionHelper {
  VersionHelper._();

  /// جلب معلومات الإصدار الحالية للبرنامج من البيئة.
  static Future<String> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  /// الحصول على رابط التحميل المناسب للمنصة الحالية.
  static String getPlatformDownloadLink(AppUpdateModel update) {
    if (kIsWeb) return ''; // لا دعم للتحديث التلقائي للويب حالياً
    if (Platform.isAndroid) return update.androidLink;
    if (Platform.isWindows) return update.windowsLink;
    if (Platform.isIOS) return update.iosLink;
    if (Platform.isMacOS) return update.macosLink;
    if (Platform.isLinux) return update.linuxLink;
    return '';
  }

  /// مقارنة إصدارين: يعيد true إذا كان الإصدار [latest] أكبر من [current].
  static bool isUpdateAvailable(String current, String latest) {
    try {
      final cParts = current.split('.').map(int.parse).toList();
      final lParts = latest.split('.').map(int.parse).toList();

      final maxLen = cParts.length > lParts.length ? cParts.length : lParts.length;
      for (var i = 0; i < maxLen; i++) {
        final c = i < cParts.length ? cParts[i] : 0;
        final l = i < lParts.length ? lParts[i] : 0;
        if (l > c) return true;
        if (c > l) return false;
      }
      return false;
    } catch (_) {
      return false; 
    }
  }
}

