import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/styles/app_theme.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/app/app_settings_model.dart';
import '../../../../data/repositories/interfaces/app_settings_repository_interface.dart';
import '../../bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/design/design_widgets.dart';

class DesignSection extends StatelessWidget {
  const DesignSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final mosque = state.request.mosque;
        if (mosque == null) return const SizedBox.shrink();
        final design = mosque.designSettings;
        final bloc = context.read<SettingsBloc>();

        return StreamBuilder<AppSettingsModel?>(
          stream: sl<IAppSettingsRepository>().streamAppSettings,
          builder: (context, appSettingsSnapshot) {
            final libraryUrls =
                appSettingsSnapshot.data?.backgroundLibraryUrls ?? [];

        return Theme(
          data: AppTheme.light(context),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Background Settings
                    BackgroundSettingsSection(
                      settings: design.background,
                      albumUrls: mosque.albumImageUrls,
                      libraryUrls: libraryUrls,
                      onTypeChanged: (type) =>
                          bloc.add(DesignBackgroundTypeChanged(type)),
                      onValueChanged: (val) =>
                          bloc.add(DesignBackgroundValueChanged(val)),
                      onAlbumUrlAdded: (url) =>
                          bloc.add(BackgroundAlbumUrlAdded(url)),
                      onAlbumUrlRemoved: (idx) =>
                          bloc.add(BackgroundAlbumUrlRemoved(idx)),
                    ),
                    const SizedBox(height: 20),

                    // 2. Color Settings
                    ColorSettingsSection(
                      colors: design.colors,
                      onPrimaryChanged: (val) =>
                          bloc.add(DesignColorChanged(DesignColorField.primary, val)),
                      onSecondaryChanged: (val) =>
                          bloc.add(DesignColorChanged(DesignColorField.secondary, val)),
                      onActiveCardChanged: (val) =>
                          bloc.add(DesignColorChanged(DesignColorField.activeCard, val)),
                      onActiveCardTextChanged: (val) => bloc.add(
                        DesignColorChanged(DesignColorField.activeCardText, val),
                      ),
                      onInactiveCardTextChanged: (val) => bloc.add(
                        DesignColorChanged(DesignColorField.inactiveCardText, val),
                      ),
                      onPrayerOverlayChanged: (val) =>
                          bloc.add(DesignColorChanged(DesignColorField.prayerOverlay, val)),
                    ),
                    const SizedBox(height: 20),

                    // 3. Font Size Settings
                    FontSizeSettingsSection(
                      fontSizes: design.fontSizes,
                      onClockSizeChanged: (val) =>
                          bloc.add(DesignFontSizeChanged(DesignFontSizeField.clock, val)),
                      onMosqueInfoSizeChanged: (val) => bloc.add(
                        DesignFontSizeChanged(DesignFontSizeField.mosqueInfo, val),
                      ),
                      onPrayersSizeChanged: (val) =>
                          bloc.add(DesignFontSizeChanged(DesignFontSizeField.prayers, val)),
                      onAnnouncementsSizeChanged: (val) => bloc.add(
                        DesignFontSizeChanged(DesignFontSizeField.announcements, val),
                      ),
                      onReligiousContentSizeChanged: (val) =>
                          bloc.add(DesignFontSizeChanged(DesignFontSizeField.religiousContent, val)),
                      onAlertsSizeChanged: (val) =>
                          bloc.add(DesignFontSizeChanged(DesignFontSizeField.alerts, val)),
                      onCountdownSizeChanged: (val) =>
                          bloc.add(DesignFontSizeChanged(DesignFontSizeField.countdown, val)),
                    ),
                    const SizedBox(height: 20),

                    // 4. Prayer Card Scale (active vs inactive ratio)
                    DesignCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DesignSectionTitle(
                            title: s.prayer_card_scale,
                            icon: Icons.aspect_ratio_outlined,
                          ),
                          Row(
                            children: [
                              const Text('1.0x'),
                              Expanded(
                                child: Slider(
                                  value: design.prayerCardScale.clamp(1.0, 3.0),
                                  min: 1.0,
                                  max: 3.0,
                                  divisions: 20,
                                  label: '${design.prayerCardScale.toStringAsFixed(1)}x',
                                  onChanged: (v) => bloc.add(
                                    PrayerCardScaleChanged(v),
                                  ),
                                ),
                              ),
                              const Text('3.0x'),
                            ],
                          ),
                          Center(
                            child: Text(
                              '${design.prayerCardScale.toStringAsFixed(1)}x',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 5. Typography Settings
                    TypographySettingsSection(
                      fontFamily: design.fontFamily,
                      numeralFormat: design.numeralFormat,
                      onFontFamilyChanged: (val) =>
                          bloc.add(DesignFontFamilyChanged(val)),
                      onNumeralFormatChanged: (val) =>
                          bloc.add(DesignNumeralFormatChanged(val)),
                    ),
                    const SizedBox(height: 20),

                    // 6. Behavior Settings
                    BehaviorSettingsSection(
                      tickerSpeed: design.tickerSpeed,
                      onTickerSpeedChanged: (val) =>
                          bloc.add(DesignTickerSpeedChanged(val)),
                      stripSpeed: design.stripSpeed,
                      onStripSpeedChanged: (val) =>
                          bloc.add(DesignStripSpeedChanged(val)),
                    ),
                    const SizedBox(
                      height: 120,
                    ), // Extra space for bottom save bar
                  ],
                ),
              ),

              // Bottom Save Bar
              if (state.hasUnsavedChanges)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: FilledButton.icon(
                      onPressed: state.isSaving
                          ? null
                          : () => bloc.add(const SaveDesignSettingsRequested()),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      icon: state.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.cloud_upload_rounded),
                      label: Text(
                        state.isSaving ? s.saving : s.save_design_settings,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
          },
        );
      },
    );
  }
}
