import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/display/display_layer_kind.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_theme.dart';
import '../../../core/utils/prayer_times_helper.dart';
import '../../../core/enums/app_mode.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../bloc/display_bloc.dart';
import '../controller/display_layer_controller.dart';
import '../widgets/layers/layer_transition_wrapper.dart';
import '../widgets/display_screen/display_base_layer.dart';
import '../widgets/display_screen/display_overlay_layer.dart';
import '../widgets/display_screen/display_settings_shortcut.dart';

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
                DisplayBaseLayer(
                  mosque: mosque,
                  state: state,
                  layerController: _layerController,
                ),
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
                      child: DisplayOverlayLayer(
                        layer: activeLayer,
                        mosque: mosque,
                        design: design,
                        recitation: state.recitation,
                        photoStudioUrl: _layerController.photoStudioUrl,
                        now: _now.value,
                        onExpired: _updateLayerInputs,
                      ),
                    );
                  },
                ),
                DisplaySettingsShortcut(
                  tooltip: S.of(context).sign_out_tooltip,
                  onPressed: () => _backToSettings(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
