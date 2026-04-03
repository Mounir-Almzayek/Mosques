import 'package:flutter/material.dart';
import '../../../../core/styles/app_theme.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../bloc/settings/settings_event.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/design/design_widgets.dart';

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
                      onTypeChanged: (type) =>
                          bloc.add(SettingsDesignBackgroundTypeChanged(type)),
                      onValueChanged: (val) =>
                          bloc.add(SettingsDesignBackgroundValueChanged(val)),
                    ),
                    const SizedBox(height: 20),

                    // 2. Color Settings
                    ColorSettingsSection(
                      colors: design.colors,
                      onPrimaryChanged: (val) =>
                          bloc.add(SettingsDesignPrimaryColorChanged(val)),
                      onSecondaryChanged: (val) =>
                          bloc.add(SettingsDesignSecondaryColorChanged(val)),
                      onActiveCardChanged: (val) =>
                          bloc.add(SettingsDesignActiveCardColorChanged(val)),
                      onActiveCardTextChanged: (val) => bloc.add(
                        SettingsDesignActiveCardTextColorChanged(val),
                      ),
                      onInactiveCardTextChanged: (val) => bloc.add(
                        SettingsDesignInactiveCardTextColorChanged(val),
                      ),
                      onPrayerOverlayChanged: (val) =>
                          bloc.add(SettingsDesignPrayerOverlayChanged(val)),
                    ),
                    const SizedBox(height: 20),

                    // 3. Font Size Settings
                    FontSizeSettingsSection(
                      fontSizes: design.fontSizes,
                      onClockSizeChanged: (val) =>
                          bloc.add(SettingsDesignClockFontSizeChanged(val)),
                      onMosqueInfoSizeChanged: (val) => bloc.add(
                        SettingsDesignMosqueInfoFontSizeChanged(val),
                      ),
                      onPrayersSizeChanged: (val) =>
                          bloc.add(SettingsDesignPrayersFontSizeChanged(val)),
                      onAnnouncementsSizeChanged: (val) => bloc.add(
                        SettingsDesignAnnouncementsFontSizeChanged(val),
                      ),
                      onContentSizeChanged: (val) =>
                          bloc.add(SettingsDesignContentFontSizeChanged(val)),
                    ),
                    const SizedBox(height: 20),

                    // 4. Typography Settings
                    TypographySettingsSection(
                      fontFamily: design.fontFamily,
                      numeralFormat: design.numeralFormat,
                      onFontFamilyChanged: (val) =>
                          bloc.add(SettingsDesignFontFamilyChanged(val)),
                      onNumeralFormatChanged: (val) =>
                          bloc.add(SettingsDesignNumeralFormatChanged(val)),
                    ),
                    const SizedBox(height: 20),

                    // 5. Behavior Settings
                    BehaviorSettingsSection(
                      tickerSpeed: design.tickerSpeed,
                      onTickerSpeedChanged: (val) =>
                          bloc.add(SettingsDesignTickerSpeedChanged(val)),
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
  }
}
