/// يمثل وضع تشغيل التطبيق (إعدادات الجوال أو شاشة عرض المسجد الذكية).
enum AppMode {
  mobileSettings,
  deviceDisplay;

  bool get isDisplay => this == AppMode.deviceDisplay;
  bool get isSettings => this == AppMode.mobileSettings;

  static AppMode fromString(String? value) {
    if (value == 'deviceDisplay') return AppMode.deviceDisplay;
    return AppMode.mobileSettings;
  }

  @override
  String toString() => name;
}
