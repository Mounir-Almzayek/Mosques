import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/display/display_layer_kind.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_theme.dart';
import '../../../core/utils/box_fit_codec.dart';
import '../../../core/utils/prayer_times_helper.dart';
import '../../../data/models/mosque/mosque_model.dart';
import '../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../../core/enums/app_mode.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../bloc/display_bloc.dart';
import '../controller/display_layer_controller.dart';
import '../widgets/background/background_widgets.dart';
import '../widgets/content/content_widgets.dart';
import '../widgets/header/header_widgets.dart';
import '../widgets/layers/alert_layer.dart';
import '../widgets/layers/iqama_adhan_layer.dart';
import '../widgets/layers/imam_tracking_layer.dart';
import '../widgets/layers/layer_transition_wrapper.dart';
import '../widgets/layers/photo_studio_layer.dart';
import '../widgets/ticker/ticker_widgets.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  Timer? _tickTimer;
  bool _religiousCycleStarted = false;
  final DisplayLayerController _layerController = DisplayLayerController();
  late PrayerTimesHelper _helper;
  final ValueNotifier<DateTime> _now = ValueNotifier(DateTime.now());

  /// Merged listenable that fires when either the layer controller or clock
  /// ticks — used to rebuild only the overlay portion of the widget tree.
  late final Listenable _overlayListenable = Listenable.merge([
    _layerController,
    _now,
  ]);

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _now.value = DateTime.now();
      _updateLayerInputs();
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _now.dispose();
    _layerController.dispose();
    super.dispose();
  }

  void _updateLayerInputs() {
    final state = context.read<DisplayBloc>().state;
    if (state is! DisplayLoaded) return;
    final mosque = state.mosque;
    final design = mosque.designSettings;

    _helper = PrayerTimesHelper(mosque);
    final phase = _helper.getPrayerDisplayPhase(
      _now.value,
      preAdhanMinutes: design.preAdhanMinutes,
      adhanMomentDurationSeconds: design.adhanMomentDurationSeconds,
    );

    _layerController.configure(
      religiousWaitSeconds: design.religiousContentWaitSeconds,
      religiousDisplaySeconds: design.religiousContentDisplaySeconds,
    );
    _layerController.updateImamTrackingSession(mosque.imamTrackingSession);
    _layerController.updateAlerts(mosque.savedAlerts);
    _layerController.updateAlbumImage(
      publishedUrl: mosque.publishedAlbumImageUrl,
      publishedAt: mosque.publishedAlbumImageAt,
      durationSeconds: mosque.publishedAlbumImageDuration,
    );
    _layerController.updatePrayerPhase(phase);
  }

  void _backToSettings(BuildContext context) async {
    await sl<IAuthRepository>().setAppModeOverride(AppMode.mobileSettings);
    if (!context.mounted) return;
    context.go(Routes.settingsPath);
  }

  Future<void> _updateImamTrackingPage(MosqueModel mosque, int pageNumber) {
    return sl<IMosqueRepository>().updateImamTrackingSession(
      mosque.imamTrackingSession.copyWith(currentPage: pageNumber),
    );
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
          if (state is! DisplayLoaded) return const SizedBox.shrink();

          final mosque = state.mosque;
          final design = mosque.designSettings;
          final colors = design.colors;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _updateLayerInputs();
              // Start the rotating religious-content cycle exactly once. Calling
              // it on every rebuild would reset the wait timer before it can
              // fire, so religious content would never appear.
              if (!_religiousCycleStarted) {
                _religiousCycleStarted = true;
                _layerController.startReligiousCycle();
              }
            }
          });

          final theme = AppTheme.light(context, fontFamily: design.fontFamily);

          return Theme(
            data: theme,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildBaseLayer(context, mosque, state),
                ListenableBuilder(
                  listenable: _overlayListenable,
                  builder: (context, _) {
                    final activeLayer = _layerController.state.activeLayer;
                    if (activeLayer == DisplayLayerKind.prayerTimes ||
                        activeLayer == DisplayLayerKind.religious) {
                      return const SizedBox.shrink();
                    }
                    return LayerTransitionWrapper(
                      activeLayer: activeLayer,
                      child: _buildOverlayLayer(
                        activeLayer,
                        mosque,
                        design,
                        colors,
                      ),
                    );
                  },
                ),
                _buildSettingsShortcut(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBaseLayer(
    BuildContext context,
    MosqueModel mosque,
    DisplayLoaded state,
  ) {
    final design = mosque.designSettings;
    final colors = design.colors;
    final media = MediaQuery.sizeOf(context);
    final padH = (media.width * 0.028).clamp(14.0, 64.0);
    final padV = (media.height * 0.022).clamp(8.0, 36.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: DisplayBackgroundImage(
            fallbackColor: colors.primaryValue,
            settings: design.background,
            albumUrls: mosque.albumImageUrls,
          ),
        ),
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
                        child: ListenableBuilder(
                          listenable: _layerController,
                          builder: (context, _) => DisplayBeigeArea(
                            mosque: mosque,
                            designSettings: design,
                            showReligiousContent:
                                _layerController.state.activeLayer ==
                                DisplayLayerKind.religious,
                            slideIndex: _layerController.religiousSlideIndex,
                          ),
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
                  platformAnnouncements: state.platformAnnouncements,
                  appSettings: state.appSettings,
                  currentVersion: state.currentVersion,
                  primaryColor: colors.secondaryValue,
                  fontSize: design.fontSizes.announcements,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayLayer(
    DisplayLayerKind layer,
    MosqueModel mosque,
    dynamic design,
    dynamic colors,
  ) {
    switch (layer) {
      case DisplayLayerKind.imamTracking:
        return ImamTrackingLayer(
          session: mosque.imamTrackingSession,
          primaryColor: colors.alertTextValue,
          backgroundColor: colors.alertBackgroundValue,
          onPageSelected: (pageNumber) {
            unawaited(_updateImamTrackingPage(mosque, pageNumber));
          },
        );
      case DisplayLayerKind.alert:
        return AlertLayer(
          alerts: mosque.savedAlerts,
          alertsFontSize: design.fontSizes.alerts,
          primaryColor: colors.alertTextValue,
          backgroundColor: colors.alertBackgroundValue,
          numeralFormat: design.numeralFormat,
          fontFamily: design.fontFamily,
          onExpired: _updateLayerInputs,
        );
      case DisplayLayerKind.photoStudio:
        return AlbumImageLayer(
          imageUrl: _layerController.photoStudioUrl ?? '',
          backgroundColor: colors.primaryValue,
          fit: boxFitFromName(mosque.publishedAlbumImageFit),
        );
      case DisplayLayerKind.iqamaAdhan:
        final helper = PrayerTimesHelper(mosque);
        final now = _now.value;
        final phase = helper.getPrayerDisplayPhase(
          now,
          preAdhanMinutes: design.preAdhanMinutes,
          adhanMomentDurationSeconds: design.adhanMomentDurationSeconds,
        );
        final remaining = phase.focusTime.difference(now);
        return IqamaAdhanLayer(
          phase: phase,
          remaining: remaining,
          designSettings: design,
          mosque: mosque,
          isFriday: now.weekday == DateTime.friday,
          countdownFontSize: design.fontSizes.countdown,
        );
      case DisplayLayerKind.religious:
        return const SizedBox.shrink(); // Handled inline by DisplayBeigeArea
      case DisplayLayerKind.prayerTimes:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSettingsShortcut() {
    return Positioned(
      top: 10,
      right: 10,
      child: IconButton(
        icon: const Icon(Icons.settings, color: Colors.transparent),
        onPressed: () => _backToSettings(context),
        tooltip: S.of(context).sign_out_tooltip,
      ),
    );
  }
}
