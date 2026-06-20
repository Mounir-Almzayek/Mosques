import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/app/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../data/repositories/interfaces/app_config_repository_interface.dart';
import '../../../../core/utils/version_helper.dart';
import '../bloc/update_bloc.dart';
import '../widgets/update_action_area.dart';
import '../widgets/update_up_to_date.dart';
import '../widgets/update_version_row.dart';

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
      child: StreamBuilder<AppConfig?>(
        stream: sl<IAppConfigRepository>().streamAppConfig,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primary));
          }

          final updateModel = snapshot.data?.update;
          if (updateModel == null) {
            return UpdateUpToDate(theme: theme, s: s);
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
                if (!isUpdateAvailable) UpdateUpToDate(theme: theme, s: s),
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
                        UpdateVersionRow(
                          theme: theme,
                          icon: Icons.smartphone_rounded,
                          label: s.update_current_version(_currentVersion),
                          color: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(height: 8),
                        // أحدث نسخة
                        UpdateVersionRow(
                          theme: theme,
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
                          UpdateActionArea(
                            downloadLink: downloadLink,
                            theme: theme,
                            s: s,
                            primary: primary,
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
}
