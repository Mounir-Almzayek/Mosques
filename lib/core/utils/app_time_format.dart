import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// تنسيق الوقت بصيغة 12 ساعة مع ص/م أو AM/PM حسب لغة الواجهة.
abstract final class AppTimeFormat {
  AppTimeFormat._();

  static String _locale(BuildContext context) =>
      Localizations.localeOf(context).toString();

  /// وقت واحد (أذان، إقامة، …) — مثل 3:45 م أو 3:45 PM.
  static String time12h(BuildContext context, DateTime d) {
    return DateFormat('h:mm a', _locale(context)).format(d);
  }

  /// ساعة كبيرة + ثوانٍ + ص/م (للرأس والساعة الكبيرة).
  static ({String hourMinute, String seconds, String period}) clockParts12h(
    BuildContext context,
    DateTime d,
  ) {
    final loc = _locale(context);
    final hourMinute = DateFormat('h:mm', loc).format(d);
    final seconds = DateFormat("':'ss", loc).format(d);
    final period = DateFormat("a", loc).format(d);
    return (hourMinute: hourMinute, seconds: seconds, period: period);
  }
}
