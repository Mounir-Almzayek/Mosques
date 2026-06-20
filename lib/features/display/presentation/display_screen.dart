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
import '../../../data/models/mosque/mosque_bootstrap.dart';
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
import '../widgets/layers/layer_transition_wrapper.dart';
import '../widgets/layers/photo_studio_layer.dart';
import '../widgets/layers/recitation_layer.dart';
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
    final design = mosque.displaySettings;

    _helper = PrayerTimesHelper(mosque);
    final phase = _helper.getPrayerDisplayPhase(
      _now.value,
      preAdhanMinutes: mosque.prayerSettings.preAdhanMinutes,
      adhanMomentDurationSeconds:
          mosque.prayerSettings.adhanMomentDurationSeconds,
    );

    _layerController.configure(
      religiousWaitSeconds: design.religiousContentWaitSeconds,
      religiousDisplaySeconds: design.religiousContentDisplaySeconds,
    );
    _layerController.updateAlerts(mosque.savedAlerts);
    _layerController.updateAlbumImage(
      publishedUrl: mosque.displaySettings.publishedAlbumUrl,
      publishedAt: mosque.displaySettings.publishedAlbumAt,
      durationSeconds:
          mosque.displaySettings.publishedAlbumDurationSeconds ?? 30,
    );
    _layerController.updateRecitationActive(state.recitation != null);
    _layerController.updatePrayerPhase(phase);
  }

  void _backToSettings(BuildContext context) async {
    await sl<IAuthRepository>().setAppModeOverride(AppMode.mobileSettings);
    if (!context.mounted) return;
    context.go(Routes.settingsPath);
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
          final design = mosque.displaySettings;

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
                      child: _buildOverlayLayer(activeLayer, mosque, design),
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

  // ignore: unused_element
  Widget _buildRecitationOverlay(Map<String, dynamic> frame) {
    final event = (frame['event'] as Map?)?.cast<String, dynamic>() ?? frame;
    final type = event['type']?.toString() ?? '';
    final surah = event['surah']?.toString();
    final ayah = event['ayah']?.toString();
    final confidence = (event['confidence'] as num?)?.toDouble();
    final message = event['message']?.toString();
    final state = event['state']?.toString();

    final title = switch (type) {
      'error' => 'ملاحظة على القراءة',
      'position' => 'تتبع القراءة',
      'session_state' => 'حالة التتبع',
      'usage' => 'تحليل القراءة',
      _ => 'تتبع القراءة',
    };
    final details = [
      if (surah != null && ayah != null) 'السورة $surah - الآية $ayah',
      ?state,
      if (message != null && message.isNotEmpty) message,
      if (confidence != null) 'الثقة ${(confidence * 100).round()}%',
    ].join('   ');

    return Positioned(
      left: 32,
      right: 32,
      top: 92,
      child: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xEE123735),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      details,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBaseLayer(
    BuildContext context,
    MosqueBootstrap mosque,
    DisplayLoaded state,
  ) {
    final design = mosque.displaySettings;
    final media = MediaQuery.sizeOf(context);
    final padH = (media.width * 0.028).clamp(14.0, 64.0);
    final padV = (media.height * 0.022).clamp(8.0, 36.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: DisplayBackgroundImage(
            fallbackColor: design.primaryColorValue,
            settings: design,
            albumUrls: design.albumImageUrls,
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
                  primaryColor: design.secondaryColorValue,
                  fontSize: design.announcementsFontSize,
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
    MosqueBootstrap mosque,
    DisplaySettings design,
  ) {
    switch (layer) {
      case DisplayLayerKind.alert:
        return AlertLayer(
          alerts: mosque.savedAlerts,
          alertsFontSize: design.alertsFontSize,
          primaryColor: design.alertTextColorValue,
          backgroundColor: design.alertBackgroundColorValue,
          numeralFormat: design.numeralFormat,
          fontFamily: design.fontFamily,
          onExpired: _updateLayerInputs,
        );
      case DisplayLayerKind.recitation:
        final displayState = context.read<DisplayBloc>().state;
        if (displayState is DisplayLoaded && displayState.recitation != null) {
          return RecitationLayer(recitation: displayState.recitation!);
        }
        return const SizedBox.shrink();
      case DisplayLayerKind.photoStudio:
        return AlbumImageLayer(
          imageUrl: _layerController.photoStudioUrl ?? '',
          backgroundColor: design.primaryColorValue,
          fit: boxFitFromName(design.publishedAlbumFit),
        );
      case DisplayLayerKind.iqamaAdhan:
        final helper = PrayerTimesHelper(mosque);
        final now = _now.value;
        final phase = helper.getPrayerDisplayPhase(
          now,
          preAdhanMinutes: mosque.prayerSettings.preAdhanMinutes,
          adhanMomentDurationSeconds:
              mosque.prayerSettings.adhanMomentDurationSeconds,
        );
        final remaining = phase.focusTime.difference(now);
        return IqamaAdhanLayer(
          phase: phase,
          remaining: remaining,
          designSettings: design,
          mosque: mosque,
          isFriday: now.weekday == DateTime.friday,
          countdownFontSize: design.countdownFontSize,
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
