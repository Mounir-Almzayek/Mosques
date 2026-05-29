import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/l10n/generated/l10n.dart';
import 'core/routes/app_pages.dart';
import 'core/di/service_locator.dart';
import 'core/styles/app_theme.dart' show AppTheme;
import 'core/widgets/keep_screen_on_lifecycle.dart';
import 'data/repositories/interfaces/mosque_repository_interface.dart';
import 'features/language/language.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              LanguageBloc(mosqueRepository: sl<IMosqueRepository>())
                ..add(const LoadLanguage()),
        ),
      ],
      child: KeepScreenOnLifecycle(
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
