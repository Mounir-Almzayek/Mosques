import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/styles/app_theme.dart';
import '../../../core/widgets/media/media_widgets.dart';
import '../../../core/enums/display_background_preset.dart';
import '../../../core/enums/display_background_type.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/mosque/announcement_model.dart';
import '../../../data/models/mosque/mosque_model.dart';
import '../../../core/enums/app_mode.dart';
import '../../auth/repository/auth_repository.dart';
import '../bloc/display_bloc.dart';
import 'widgets/alerts/alerts_widgets.dart';
import 'widgets/background/background_widgets.dart';
import 'widgets/content/content_widgets.dart';
import 'widgets/header/header_widgets.dart';
import 'widgets/ticker/ticker_widgets.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  Timer? _alertRefreshTimer;

  void _backToSettings(BuildContext context) async {
    await AuthRepository.setAppModeOverride(AppMode.mobileSettings);
    if (!context.mounted) return;
    context.go(Routes.settingsPath);
  }

  @override
  void initState() {
    super.initState();
    _precacheBackgrounds();
    // تفعيل ريفريش دوري كل ثانية للتأكد من دقة توقيت ظهور واختفاء التنبيهات
    _alertRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _alertRefreshTimer?.cancel();
    super.dispose();
  }

  void _precacheBackgrounds() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<DisplayBloc>().state;
      if (state is DisplayLoaded) {
        final d = state.mosque.designSettings;
        if (d.background.type == DisplayBackgroundType.image) {
          final path =
              DisplayBackgroundPreset.fromStorageId(d.background.value).assetPath;
          final media = MediaQuery.of(context);
          final physicalWidth =
              (media.size.width * media.devicePixelRatio).round();
          final cappedWidth = physicalWidth > 1920 ? 1920 : physicalWidth;
          precacheOptimizedAsset(context, path, cacheWidth: cappedWidth);
        }
      }
    });
  }

  /// خوارزمية ذكية لاختيار الإعلان العاجل النشط حالياً بناءً على الوقت والمدة
  AnnouncementModel? _getActiveAlert(MosqueModel mosque) {
    if (mosque.activeAlerts.isEmpty) return null;
    final now = DateTime.now();
    for (final a in mosque.activeAlerts) {
      final expiry = a.startDate.add(Duration(seconds: a.displayDurationSeconds));
      if (now.isAfter(a.startDate) && now.isBefore(expiry)) {
        return a;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DisplayBloc, DisplayState>(
        builder: (context, state) {
          if (state is DisplayLoading || state is DisplayInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DisplayError) {
            final s = S.of(context);
            final msg = state.message == 'no_mosque'
                ? s.display_error_no_mosque
                : state.message;
            return Center(
              child: Text(
                msg,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state is DisplayLoaded) {
            final mosque = state.mosque;
            final platformAds = state.platformAnnouncements;
            final design = mosque.designSettings;
            final colors = design.colors;

            final activeAlert = _getActiveAlert(mosque);

            // Centralized theme lookup with dynamic font support.
            final theme = AppTheme.light(
              context,
              fontFamily: design.fontFamily,
            );

            return Theme(
              data: theme,
              child: Builder(
                builder: (context) {
                  // فصل تام: إما صفحة التنبيهات أو الصفحة العادية - بدون أي ستاك مشترك.
                  if (activeAlert != null) {
                    return DisplayAlertView(
                      alerts: mosque.activeAlerts,
                      primaryColor: colors.activeCardTextValue,
                      backgroundColor: colors.activeCardValue,
                      numeralFormat: design.numeralFormat,
                      fontFamily: design.fontFamily,
                      onExpired: () => setState(() {}),
                    );
                  }

                  // الصفحة العادية للعرض
                  return _buildRegularDisplay(
                    context,
                    mosque,
                    platformAds,
                    design,
                    colors,
                    state,
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRegularDisplay(
    BuildContext context,
    MosqueModel mosque,
    List<AnnouncementModel> platformAds,
    dynamic design, // DesignSettingsModel
    dynamic colors, // DesignColorSettings
    DisplayLoaded state,
  ) {
    final media = MediaQuery.sizeOf(context);
    final padH = (media.width * 0.028).clamp(14.0, 64.0);
    final padV = (media.height * 0.022).clamp(8.0, 36.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Background
        Positioned.fill(
          child: DisplayBackgroundImage(
            fallbackColor: colors.primaryValue,
            settings: design.background,
          ),
        ),

        // 2. Main Content
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: padH,
                          vertical: padV,
                        ),
                        child: TopHeaderWidget(
                          mosque: mosque,
                          designSettings: design,
                        ),
                      ),
                      Expanded(
                        child: DisplayBeigeArea(
                          mosque: mosque,
                          platformAnnouncements: platformAds,
                          designSettings: design,
                          prayersFontSize: design.fontSizes.prayers,
                          contentFontSize: design.fontSizes.content,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                minimum: EdgeInsets.zero,
                child: DisplayTickerBar(
                  mosque: mosque,
                  platformAnnouncements: platformAds,
                  appSettings: state.appSettings,
                  currentVersion: state.currentVersion,
                  primaryColor: colors.secondaryValue,
                  fontSize: design.fontSizes.announcements,
                ),
              ),
            ],
          ),
        ),
        _buildSettingsShortcut(),
      ],
    );
  }

  Widget _buildSettingsShortcut() {
    return Positioned(
      top: 10,
      right: 10,
      child: IconButton(
        icon: const Icon(
          Icons.settings,
          color: Colors.transparent,
        ),
        onPressed: () => _backToSettings(context),
        tooltip: S.of(context).sign_out_tooltip,
      ),
    );
  }
}

