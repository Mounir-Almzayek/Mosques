import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Re-enables keep-screen-on after returning from the background
/// (some devices reset the setting).
class KeepScreenOnLifecycle extends StatefulWidget {
  const KeepScreenOnLifecycle({super.key, required this.child});

  final Widget child;

  /// Prevents the screen from sleeping while the app is running
  /// (complements android:keepScreenOn and the iOS idle timer).
  static Future<void> enable() async {
    try {
      await WakelockPlus.enable();
    } catch (e, st) {
      debugPrint('Keep screen on: $e\n$st');
    }
  }

  @override
  State<KeepScreenOnLifecycle> createState() => _KeepScreenOnLifecycleState();
}

class _KeepScreenOnLifecycleState extends State<KeepScreenOnLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    KeepScreenOnLifecycle.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      KeepScreenOnLifecycle.enable();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
