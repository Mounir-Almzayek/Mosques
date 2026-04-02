import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/styles/app_theme.dart';
import '../../../core/widgets/optimized_image.dart';
import '../../../core/enums/display_background_preset.dart';
import '../../../core/enums/display_background_type.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../bloc/display_bloc.dart';
import 'widgets/display_alert_overlay.dart';
import 'widgets/display_background_image.dart';
import 'widgets/display_beige_area.dart';
import 'widgets/display_ticker_bar.dart';
import 'widgets/top_header_widget.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  void _backToSettings(BuildContext context) {
    if (!context.mounted) return;
    context.go(Routes.settingsPath);
  }

  @override
  void initState() {
    super.initState();
    _precacheBackgrounds();
  }

  void _precacheBackgrounds() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<DisplayBloc>().state;
      if (state is DisplayLoaded) {
        final d = state.mosque.designSettings;
        if (d.background.type == DisplayBackgroundType.image) {
          final path = DisplayBackgroundPreset.fromStorageId(d.background.value).assetPath;
          final media = MediaQuery.of(context);
          final physicalWidth = (media.size.width * media.devicePixelRatio).round();
          final cappedWidth = physicalWidth > 1920 ? 1920 : physicalWidth;
          precacheOptimizedAsset(context, path, cacheWidth: cappedWidth);
        }
      }
    });
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

            // Centralized theme lookup with dynamic font support.
            final theme = AppTheme.light(
              context,
              fontFamily: design.fontFamily,
            );

            final media = MediaQuery.sizeOf(context);
            final padH = (media.width * 0.028).clamp(14.0, 64.0);
            final padV = (media.height * 0.022).clamp(8.0, 36.0);

            return Theme(
              data: theme,
              child: Builder(
                builder: (context) => Stack(
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
                              primaryColor: colors.secondaryValue,
                              fontSize: design.fontSizes.announcements,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. High-Priority Alert Overlay
                    Positioned.fill(
                      child: DisplayAlertOverlay(
                        alerts: mosque.activeAlerts,
                        primaryColor: colors.activeCardTextValue,
                        backgroundColor: colors.activeCardValue.withValues(
                          alpha: 0.98,
                        ),
                        numeralFormat: design.numeralFormat,
                        fontFamily: design.fontFamily,
                      ),
                    ),

                    // 4. Hidden Settings Shortcut
                    Positioned(
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
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
