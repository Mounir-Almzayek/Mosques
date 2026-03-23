import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/l10n/generated/l10n.dart';
import 'core/routes/app_pages.dart';
import 'core/services/hive_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/firebase_service.dart';
import 'core/styles/app_theme.dart' show AppTheme;
import 'features/language/bloc/language/language_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional env overrides (file must exist under assets/ for web — see assets/.env)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint("DotEnv load failed: $e");
  }

  // Initialize services
  await StorageService.init();
  await HiveService.init();
  await FirebaseService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LanguageBloc()..add(const LoadLanguage())),
      ],
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
    );
  }
}
