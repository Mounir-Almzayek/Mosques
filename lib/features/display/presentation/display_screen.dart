import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/display/display_layer_kind.dart';
import '../../../core/enums/display_background_preset.dart';
import '../../../core/enums/display_background_type.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_theme.dart';
import '../../../core/utils/prayer_times_helper.dart';
import '../../../core/widgets/media/media_widgets.dart';
import '../../../data/models/mosque/mosque_model.dart';
import '../../../core/enums/app_mode.dart';
import '../../auth/repository/auth_repository.dart';
import '../bloc/display_bloc.dart';
import '../controller/display_layer_controller.dart';
import 'widgets/background/background_widgets.dart';
import 'widgets/content/content_widgets.dart';
import 'widgets/header/header_widgets.dart';
import 'widgets/layers/alert_layer.dart';
import 'widgets/layers/iqama_adhan_layer.dart';
import 'widgets/layers/layer_transition_wrapper.dart';
import 'widgets/layers/photo_studio_layer.dart';
import 'widgets/layers/religious_content_layer.dart';
import 'widgets/ticker/ticker_widgets.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  Timer? _tickTimer;
  final DisplayLayerController _layerController = DisplayLayerController();
  late PrayerTimesHelper _helper;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _layerController.addListener(_onLayerChange);
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _now = DateTime.now();
      _updateLayerInputs();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _layerController.removeListener(_onLayerChange);
    _layerController.dispose();
    super.dispose();
  }

  void _onLayerChange() {
    if (mounted) setState(() {});
  }

  void _updateLayerInputs() {
    final state = context.read<DisplayBloc>().state;
    if (state is! DisplayLoaded) return;
    final mosque = state.mosque;
    final design = mosque.designSettings;

    _helper = PrayerTimesHelper(mosque);
    final phase = _helper.getPrayerDisplayPhase(_now, preAdhanMinutes: design.preAdhanMinutes);

    _layerController.configure(
      religiousWaitSeconds: design.religiousContentWaitSeconds,
      religiousDisplaySeconds: design.religiousContentDisplaySeconds,
    );
    _layerController.updateAlerts(mosque.activeAlerts);
    _layerController.updatePrayerPhase(phase);
  }

  void _backToSettings(BuildContext context) async {
    await AuthRepository.setAppModeOverride(AppMode.mobileSettings);
    if (!context.mounted) return;
    context.go(Routes.settingsPath);
  }

  void _precacheBackgrounds(MosqueModel mosque) {
    final d = mosque.designSettings;
    if (d.background.type == DisplayBackgroundType.image) {
      final path = DisplayBackgroundPreset.fromStorageId(d.background.value).assetPath;
      final media = MediaQuery.of(context);
      final cappedWidth = (media.size.width * media.devicePixelRatio).round().clamp(0, 1920);
      precacheOptimizedAsset(context, path, cacheWidth: cappedWidth);
    }
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
            final msg = state.message == 'no_mosque' ? s.display_error_no_mosque : state.message;
            return Center(child: Text(msg, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center));
          }
          if (state is! DisplayLoaded) return const SizedBox.shrink();

          final mosque = state.mosque;
          final design = mosque.designSettings;
          final colors = design.colors;
          final activeLayer = _layerController.state.activeLayer;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _precacheBackgrounds(mosque);
              _updateLayerInputs();
              _layerController.startReligiousCycle();
            }
          });

          final theme = AppTheme.light(context, fontFamily: design.fontFamily);

          return Theme(
            data: theme,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildBaseLayer(context, mosque, state),
                if (activeLayer != DisplayLayerKind.prayerTimes)
                  LayerTransitionWrapper(
                    activeLayer: activeLayer,
                    child: _buildOverlayLayer(activeLayer, mosque, design, colors),
                  ),
                _buildSettingsShortcut(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBaseLayer(BuildContext context, MosqueModel mosque, DisplayLoaded state) {
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
                        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
                        child: TopHeaderWidget(mosque: mosque, designSettings: design),
                      ),
                      Expanded(
                        child: DisplayBeigeArea(mosque: mosque, designSettings: design),
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
      case DisplayLayerKind.alert:
        return AlertLayer(
          alerts: mosque.activeAlerts,
          primaryColor: colors.activeCardTextValue,
          backgroundColor: colors.activeCardValue,
          numeralFormat: design.numeralFormat,
          fontFamily: design.fontFamily,
          onExpired: () => setState(() {}),
        );
      case DisplayLayerKind.photoStudio:
        return PhotoStudioLayer(
          imageUrl: _layerController.photoStudioUrl ?? '',
          backgroundColor: colors.primaryValue,
        );
      case DisplayLayerKind.iqamaAdhan:
        final helper = PrayerTimesHelper(mosque);
        final phase = helper.getPrayerDisplayPhase(_now, preAdhanMinutes: design.preAdhanMinutes);
        final remaining = phase.focusTime.difference(_now);
        return IqamaAdhanLayer(
          phase: phase,
          remaining: remaining,
          designSettings: design,
          isFriday: _now.weekday == DateTime.friday,
        );
      case DisplayLayerKind.religious:
        return ReligiousContentLayer(
          mosque: mosque,
          designSettings: design,
          slideIndex: _layerController.religiousSlideIndex,
        );
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
