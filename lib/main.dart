import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'core/l10n/generated/l10n.dart';
import 'core/routes/app_pages.dart';
import 'core/services/hive_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/firebase_service.dart';
import 'core/styles/app_theme.dart' show AppTheme;
import 'features/language/bloc/language/language_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // منع إطفاء الشاشة / السكون أثناء تشغيل التطبيق (يُكمّل android:keepScreenOn و iOS idle timer).
  await _enableKeepScreenOn();

  // Optional env overrides (file is stored at assets/.env)
  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (e) {
    debugPrint("DotEnv load failed: $e");
  }

  // Initialize services
  await StorageService.init();
  await HiveService.init();
  await FirebaseService.init();

  runApp(const MyApp());
}

Future<void> _enableKeepScreenOn() async {
  try {
    await WakelockPlus.enable();
  } catch (e, st) {
    debugPrint('Keep screen on: $e\n$st');
  }
}

/// يعيد تفعيل منع السكون بعد العودة من الخلفية (بعض الأجهزة قد تعيد الإعدادات).
class _KeepScreenOnLifecycle extends StatefulWidget {
  const _KeepScreenOnLifecycle({required this.child});

  final Widget child;

  @override
  State<_KeepScreenOnLifecycle> createState() => _KeepScreenOnLifecycleState();
}

class _KeepScreenOnLifecycleState extends State<_KeepScreenOnLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableKeepScreenOn();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _enableKeepScreenOn();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LanguageBloc()..add(const LoadLanguage())),
      ],
      child: _KeepScreenOnLifecycle(
        child: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, state) {
            return ScreenUtilInit(
              minTextAdapt: true,
              splitScreenMode: true,
              rebuildFactor: RebuildFactors.always,
              builder: (context, child) {
                return MaterialApp.router(
                  theme: AppTheme.light(context),
                  debugShowCheckedModeBanner: false,
                  locale: state.language.locale,
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: S.delegate.supportedLocales,
                  routerConfig: appPages,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
