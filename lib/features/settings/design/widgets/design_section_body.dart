import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_theme.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../data/models/app/app_config.dart';
import '../../../../data/repositories/interfaces/app_config_repository_interface.dart';
import '../bloc/design_bloc.dart';
import 'design_save_bar.dart';
import 'design_widgets.dart';

class DesignSectionBody extends StatelessWidget {
  const DesignSectionBody({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<DesignBloc, DesignState>(
      listenWhen: (prev, curr) =>
          prev.isSaving != curr.isSaving ||
          (curr.error != null && prev.error == null),
      listener: (context, state) {
        if (state.isSaving) {
          UnifiedSnackbar.info(context, message: S.of(context).saving);
        } else if (state.error != null) {
          UnifiedSnackbar.error(context, message: state.error!);
        } else {
          UnifiedSnackbar.hide(context);
          UnifiedSnackbar.success(
            context,
            message: S.of(context).saved_successfully,
          );
        }
      },
      child: BlocBuilder<DesignBloc, DesignState>(
        builder: (context, state) {
          final mosque = state.mosque;
          if (mosque == null) return const SizedBox.shrink();

          final design = mosque.displaySettings;
          final bloc = context.read<DesignBloc>();

          return StreamBuilder<AppConfig?>(
            stream: sl<IAppConfigRepository>().streamAppConfig,
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
                          BackgroundSettingsSection(
                            backgroundType: design.backgroundTypeKind,
                            backgroundValue: design.backgroundValue,
                            albumUrls: mosque.displaySettings.albumImageUrls,
                            libraryUrls: libraryUrls,
                            onTypeChanged: (type) {
                              bloc.add(DesignBackgroundTypeChanged(type));
                            },
                            onValueChanged: (value) {
                              bloc.add(DesignBackgroundValueChanged(value));
                            },
                            onAlbumUrlRemoved: (index) {
                              bloc.add(BackgroundAlbumUrlRemoved(index));
                            },
                          ),
                          const SizedBox(height: 20),
                          ColorSettingsSection(
                            colors: design,
                            onPrimaryChanged: (value) => bloc.add(
                              DesignColorChanged(
                                DesignColorField.primary,
                                value,
                              ),
                            ),
                            onSecondaryChanged: (value) => bloc.add(
                              DesignColorChanged(
                                DesignColorField.secondary,
                                value,
                              ),
                            ),
                            onActiveCardChanged: (value) => bloc.add(
                              DesignColorChanged(
                                DesignColorField.activeCard,
                                value,
                              ),
                            ),
                            onActiveCardTextChanged: (value) => bloc.add(
                              DesignColorChanged(
                                DesignColorField.activeCardText,
                                value,
                              ),
                            ),
                            onInactiveCardTextChanged: (value) => bloc.add(
                              DesignColorChanged(
                                DesignColorField.inactiveCardText,
                                value,
                              ),
                            ),
                            onPrayerOverlayChanged: (value) => bloc.add(
                              DesignColorChanged(
                                DesignColorField.prayerOverlay,
                                value,
                              ),
                            ),
                            onCountdownBackgroundChanged: (value) => bloc.add(
                              DesignColorChanged(
                                DesignColorField.countdownBackground,
                                value,
                              ),
                            ),
                            onCountdownTextChanged: (value) => bloc.add(
                              DesignColorChanged(
                                DesignColorField.countdownText,
                                value,
                              ),
                            ),
                            onAlertBackgroundChanged: (value) => bloc.add(
                              DesignColorChanged(
                                DesignColorField.alertBackground,
                                value,
                              ),
                            ),
                            onAlertTextChanged: (value) => bloc.add(
                              DesignColorChanged(
                                DesignColorField.alertText,
                                value,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FontSizeSettingsSection(
                            fontSizes: design,
                            onClockSizeChanged: (value) => bloc.add(
                              DesignFontSizeChanged(
                                DesignFontSizeField.clock,
                                value,
                              ),
                            ),
                            onMosqueInfoSizeChanged: (value) => bloc.add(
                              DesignFontSizeChanged(
                                DesignFontSizeField.mosqueInfo,
                                value,
                              ),
                            ),
                            onPrayersSizeChanged: (value) => bloc.add(
                              DesignFontSizeChanged(
                                DesignFontSizeField.prayers,
                                value,
                              ),
                            ),
                            onAnnouncementsSizeChanged: (value) => bloc.add(
                              DesignFontSizeChanged(
                                DesignFontSizeField.announcements,
                                value,
                              ),
                            ),
                            onReligiousContentSizeChanged: (value) => bloc.add(
                              DesignFontSizeChanged(
                                DesignFontSizeField.religiousContent,
                                value,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          PrayerCardScaleSection(
                            s: s,
                            value: design.prayerCardScale,
                            onChanged: (value) {
                              bloc.add(PrayerCardScaleChanged(value));
                            },
                          ),
                          const SizedBox(height: 20),
                          TypographySettingsSection(
                            fontFamily: design.fontFamily,
                            numeralFormat: design.numeralFormat,
                            onFontFamilyChanged: (value) {
                              bloc.add(DesignFontFamilyChanged(value));
                            },
                            onNumeralFormatChanged: (value) {
                              bloc.add(DesignNumeralFormatChanged(value));
                            },
                          ),
                          const SizedBox(height: 20),
                          BehaviorSettingsSection(
                            tickerSpeed: design.tickerSpeed,
                            onTickerSpeedChanged: (value) {
                              bloc.add(DesignTickerSpeedChanged(value));
                            },
                            stripSpeed: design.stripSpeed,
                            onStripSpeedChanged: (value) {
                              bloc.add(DesignStripSpeedChanged(value));
                            },
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                    if (state.hasUnsavedChanges)
                      DesignSaveBar(
                        isSaving: state.isSaving,
                        savingLabel: s.saving,
                        saveLabel: s.save_design_settings,
                        onSave: () => bloc.add(const SaveDesignRequested()),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
