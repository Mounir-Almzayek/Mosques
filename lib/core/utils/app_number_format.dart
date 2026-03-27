import '../enums/app_numeral_format.dart';

/// Formatter to convert English numerals to Arabic numerals based on settings.
abstract final class AppNumberFormat {
  AppNumberFormat._();

  static const _en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  static const _ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  /// Formats a string (usually a number or time) using the specified numeral format.
  static String format(String input, AppNumeralFormat format) {
    var output = input;
    if (format == AppNumeralFormat.arabic) {
      // Force Arabic Numerals
      for (var i = 0; i < 10; i++) {
        output = output.replaceAll(_en[i], _ar[i]);
      }
    } else {
      // Force English Numerals
      for (var i = 0; i < 10; i++) {
        output = output.replaceAll(_ar[i], _en[i]);
      }
    }
    return output;
  }
}

/// Extension for easier access to number formatting on String.
extension AppNumberFormatExtension on String {
  String formatNumerals(AppNumeralFormat format) =>
      AppNumberFormat.format(this, format);
}
