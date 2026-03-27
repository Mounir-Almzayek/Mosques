enum AppNumeralFormat {
  english('en', '1234567890'),
  arabic('ar', '١٢٣٤٥٦٧٨٩٠');

  final String code;
  final String sample;

  const AppNumeralFormat(this.code, this.sample);

  static AppNumeralFormat fromCode(String code) {
    return AppNumeralFormat.values.firstWhere(
      (e) => e.code == code,
      orElse: () => AppNumeralFormat.english,
    );
  }
}
