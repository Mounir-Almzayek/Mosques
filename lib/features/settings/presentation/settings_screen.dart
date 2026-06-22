import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/enums/app_mode.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../core/widgets/focus/focus_widgets.dart';
import '../../../core/widgets/navigation/zoom_drawer.dart';
import '../../../data/models/mosque/mosque_bootstrap.dart';
import '../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../../data/repositories/interfaces/notifications_repository_interface.dart';
import '../core/widgets/settings_app_bar.dart';
import '../core/widgets/settings_zoom_drawer_content.dart';
import '../core/refresh/settings_refresh_scope.dart';

import '../general/presentation/general_section.dart';
import '../mosque_info/presentation/mosque_info_section.dart';
import '../notifications/bloc/notifications_bloc.dart';
import '../notifications/presentation/notifications_section.dart';
import '../iqama/presentation/prayer_iqama_section.dart';
import '../religious_content/presentation/religious_content_section.dart';
import '../design/presentation/design_section.dart';
import '../album/presentation/album_section.dart';
import '../announcements/presentation/announcement_section.dart';
import '../alerts/presentation/alerts_section.dart';
import '../profile/presentation/profile_section.dart';
import '../about/presentation/about_section.dart';
import '../update/presentation/update_section.dart';
import '../recitation/recitation.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _sectionIndex = 0;
  final ZoomDrawerController _drawerController = ZoomDrawerController();
  final SettingsRefreshRegistry _refreshRegistry = SettingsRefreshRegistry();
  int _mosqueStreamVersion = 0;

  @override
  void dispose() {
    _drawerController.dispose();
    _refreshRegistry.dispose();
    super.dispose();
  }

  void _signOut() async {
    _drawerController.close();
    await sl<IAuthRepository>().logout();
    if (mounted) {
      context.go(Routes.splashPath);
    }
  }

  Future<void> _refreshAccount() async {
    await sl<IAuthRepository>().refreshCurrentUser();
    if (!mounted) return;
    setState(() => _mosqueStreamVersion++);
  }

  Future<void> _refreshSettings({required bool hasMosque}) async {
    final canContinue = await _resolvePendingChanges();
    if (!mounted || !canContinue) return;
    final s = S.of(context);

    try {
      if (!hasMosque) {
        await _refreshAccount();
        return;
      }
      await sl<IMosqueRepository>().fetchActiveMosqueFromServer();
      if (!mounted) return;
      UnifiedSnackbar.success(context, message: s.settings_refreshed);
    } catch (error) {
      if (!mounted) return;
      UnifiedSnackbar.error(context, message: error.toString());
    }
  }

  Future<void> _selectSection(int index) async {
    if (index == _sectionIndex) {
      _drawerController.close();
      return;
    }
    final canContinue = await _resolvePendingChanges();
    if (!mounted || !canContinue) return;
    _drawerController.close();
    setState(() => _sectionIndex = index);
  }

  Future<bool> _resolvePendingChanges() async {
    final dirtyDelegates = _refreshRegistry.dirtyDelegates;
    if (dirtyDelegates.isEmpty) return true;

    final s = S.of(context);
    final decision = await _showUnsavedChangesDialog(dirtyDelegates);
    if (!mounted) return false;
    if (decision == _PendingChangesDecision.cancel || decision == null) {
      return false;
    }
    if (decision == _PendingChangesDecision.discard) {
      _refreshRegistry.discardDirty();
      return true;
    }

    try {
      UnifiedSnackbar.info(context, message: s.saving);
      await _refreshRegistry.saveDirty();
      return true;
    } catch (error) {
      if (!mounted) return false;
      UnifiedSnackbar.error(context, message: error.toString());
      return false;
    }
  }

  Future<_PendingChangesDecision?> _showUnsavedChangesDialog(
    List<SettingsRefreshDelegate> dirtyDelegates,
  ) {
    final labels = dirtyDelegates.map((delegate) => delegate.label).toSet();
    return showDialog<_PendingChangesDecision>(
      context: context,
      builder: (context) => _PendingChangesDialog(labels: labels.toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return StreamBuilder<MosqueBootstrap?>(
      key: ValueKey(_mosqueStreamVersion),
      stream: sl<IMosqueRepository>().streamActiveMosque,
      builder: (context, snapshot) {
        final mosque = snapshot.data;
        final hasMosque = mosque != null;
        final waitingForFirstValue =
            snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData;
        final mosqueName = mosque?.name ?? '';
        final showRecitation = (mosque?.id.isNotEmpty ?? false);
        final sectionCount = showRecitation ? 13 : 12;
        if (_sectionIndex >= sectionCount) {
          _sectionIndex = sectionCount - 1;
        }
        final showNoMosqueState =
            !waitingForFirstValue &&
            !hasMosque &&
            _sectionRequiresMosque(_sectionIndex, showRecitation);
        return ListenableBuilder(
          listenable: _drawerController,
          builder: (context, _) {
            return BlocProvider<NotificationsBloc>(
              create: (_) =>
                  NotificationsBloc(repository: sl<INotificationsRepository>())
                    ..add(const LoadNotifications()),
              child: SettingsRefreshScope(
                registry: _refreshRegistry,
                child: TvNavigationScope(
                  onDismiss: () {
                    if (_drawerController.isOpen) {
                      _drawerController.close();
                    } else if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: ZoomDrawer(
                    controller: _drawerController,
                    menuScreen: SettingsZoomDrawerContent(
                      selectedIndex: _sectionIndex,
                      isOpen: _drawerController.isOpen,
                      showRecitation: showRecitation,
                      onSelectSection: _selectSection,
                      onSignOut: _signOut,
                    ),
                    mainScreen: Scaffold(
                      appBar: SettingsAppBar(
                        sectionIndex: _sectionIndex,
                        mosqueName: mosqueName,
                        showRecitation: showRecitation,
                        onNotificationsPressed: () => _selectSection(1),
                        onMenuPressed: _drawerController.toggle,
                        popupMenuBuilder: (BuildContext context) => [
                          if (hasMosque)
                            PopupMenuItem<String>(
                              value: 'smart_screen',
                              child: Text(s.enable_smart_screen),
                            ),
                        ],
                        onPopupMenuSelected: (value) async {
                          if (value == 'smart_screen') {
                            await sl<IAuthRepository>().setAppModeOverride(
                              AppMode.deviceDisplay,
                            );
                            if (!context.mounted) return;
                            context.go(Routes.displayPath);
                          }
                        },
                      ),
                      // Keep content readable on wide desktop screens by capping
                      // its width and centering it. On phones/tablets the cap is
                      // wider than the viewport, so it has no effect.
                      body: RefreshIndicator(
                        onRefresh: () => _refreshSettings(hasMosque: hasMosque),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1000),
                            child: waitingForFirstValue
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : showNoMosqueState
                                ? SettingsNoActiveMosqueState(
                                    onRefresh: _refreshAccount,
                                    onSignOut: _signOut,
                                  )
                                : IndexedStack(
                                    index: _sectionIndex,
                                    sizing: StackFit.expand,
                                    children: [
                                      const GeneralSection(),
                                      const NotificationsSection(),
                                      const MosqueInfoSection(),
                                      const PrayerIqamaSection(),
                                      const ReligiousContentSection(),
                                      const DesignSection(),
                                      const AnnouncementSection(),
                                      const AlbumSection(),
                                      const AlertsSection(),
                                      if (showRecitation)
                                        const RecitationSection(),
                                      const ProfileSection(),
                                      const AboutSection(),
                                      const UpdateSection(),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _sectionRequiresMosque(int index, bool showRecitation) {
    if (index <= 1) return false;
    return index <= (showRecitation ? 9 : 8);
  }
}

enum _PendingChangesDecision { save, discard, cancel }

class _PendingChangesDialog extends StatelessWidget {
  const _PendingChangesDialog({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryWhisper,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s.settings_refresh_unsaved_title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              s.settings_refresh_unsaved_message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
                height: 1.45,
              ),
            ),
            if (labels.isNotEmpty) ...[
              const SizedBox(height: 14),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primaryWhisper.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: labels
                        .map(
                          (label) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 7,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    label,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_PendingChangesDecision.cancel),
                  child: Text(s.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(_PendingChangesDecision.discard),
                  child: Text(s.settings_refresh_discard),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_PendingChangesDecision.save),
                  child: Text(s.settings_refresh_save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsNoActiveMosqueState extends StatelessWidget {
  const SettingsNoActiveMosqueState({
    super.key,
    required this.onRefresh,
    required this.onSignOut,
  });

  final Future<void> Function() onRefresh;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.mosque_outlined,
                    size: 56,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.settings_no_active_mosque_title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.settings_no_active_mosque_subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton.elevated(
                    label: s.refresh,
                    leadingIcon: Icons.refresh_rounded,
                    onPressed: () => onRefresh(),
                    expand: false,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 12),
                  AppButton.text(
                    label: s.sign_out,
                    leadingIcon: Icons.logout_rounded,
                    onPressed: onSignOut,
                    expand: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
