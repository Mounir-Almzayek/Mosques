import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/update/update_status.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../data/models/app/app_settings_model.dart';
import '../../../../data/repositories/app_settings_repository.dart';
import '../../../../core/utils/version_helper.dart';
import '../../bloc/update/update_bloc.dart';

class UpdateSection extends StatefulWidget {
  const UpdateSection({super.key});

  @override
  State<UpdateSection> createState() => _UpdateSectionState();
}

class _UpdateSectionState extends State<UpdateSection> {
  String _currentVersion = '...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final v = await VersionHelper.getCurrentVersion();
    if (mounted) setState(() => _currentVersion = v);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return BlocProvider(
      create: (context) => UpdateBloc(),
      child: StreamBuilder<AppSettingsModel?>(
        stream: AppSettingsRepository.streamAppSettings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primary));
          }

          final updateModel = snapshot.data?.update;
          if (updateModel == null) {
            return _buildUpToDate(theme, s);
          }

          final latestVersion = updateModel.latestVersion;
          final isUpdateAvailable = VersionHelper.isUpdateAvailable(
            _currentVersion,
            latestVersion,
          );
          final downloadLink = VersionHelper.getPlatformDownloadLink(
            updateModel,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isUpdateAvailable) _buildUpToDate(theme, s),
                if (!isUpdateAvailable) const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // أيقونة التحديث
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.system_update_rounded,
                            size: 44,
                            color: primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (isUpdateAvailable)
                          Text(
                            s.update_title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 16),
                        // النسخة الحالية
                        _buildVersionRow(
                          theme,
                          icon: Icons.smartphone_rounded,
                          label: s.update_current_version(_currentVersion),
                          color: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(height: 8),
                        // أحدث نسخة
                        _buildVersionRow(
                          theme,
                          icon: Icons.cloud_download_rounded,
                          label: s.update_latest_version(latestVersion),
                          color: isUpdateAvailable
                              ? primary
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                          bold: isUpdateAvailable,
                        ),
                        if (isUpdateAvailable &&
                            updateModel.releaseNotes.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              updateModel.releaseNotes,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        if (isUpdateAvailable)
                          BlocConsumer<UpdateBloc, UpdateState>(
                            listener: (context, state) {
                              if (state.status == UpdateStatus.failure) {
                                UnifiedSnackbar.error(
                                  context,
                                  message: state.error ?? s.update_failure,
                                );
                              }
                            },
                            builder: (context, state) {
                              if (downloadLink.isEmpty) {
                                return Text(
                                  s.update_no_link,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              }

                              if (state.status == UpdateStatus.downloading) {
                                return Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: state.progress,
                                        color: primary,
                                        backgroundColor: primary.withValues(
                                          alpha: 0.15,
                                        ),
                                        minHeight: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      s.update_downloading(
                                        (state.progress * 100).toStringAsFixed(
                                          1,
                                        ),
                                      ),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                );
                              }

                              if (state.status == UpdateStatus.success) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      s.update_success,
                                      style: TextStyle(
                                        color: primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<UpdateBloc>().add(
                                      DownloadUpdateRequested(downloadLink),
                                    );
                                  },
                                  icon: const Icon(Icons.download_rounded),
                                  label: Text(
                                    s.update_download,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVersionRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required Color color,
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildUpToDate(ThemeData theme, S s) {
    final primary = theme.colorScheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.verified_rounded, size: 44, color: primary),
            ),
            const SizedBox(height: 16),
            Text(
              s.update_up_to_date,
              style: theme.textTheme.titleMedium?.copyWith(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

