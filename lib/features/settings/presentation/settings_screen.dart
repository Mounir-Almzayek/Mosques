import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/enums/app_mode.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/focus/focus_widgets.dart';
import '../../../core/widgets/navigation/zoom_drawer.dart';
import '../../../data/models/mosque/mosque_model.dart';
import '../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../core/widgets/settings_app_bar.dart';
import '../core/widgets/settings_zoom_drawer_content.dart';

import '../general/presentation/general_section.dart';
import '../iqama/presentation/prayer_iqama_section.dart';
import '../religious_content/presentation/religious_content_section.dart';
import '../design/presentation/design_section.dart';
import '../album/presentation/album_section.dart';
import '../announcements/presentation/announcement_section.dart';
import '../alerts/presentation/alerts_section.dart';
import '../profile/presentation/profile_section.dart';
import '../about/presentation/about_section.dart';
import '../update/presentation/update_section.dart';
import '../../recitation/presentation/recitation_page.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _sectionIndex = 0;
  final ZoomDrawerController _drawerController = ZoomDrawerController();

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void _signOut() async {
    _drawerController.close();
    await sl<IAuthRepository>().logout();
    if (mounted) {
      context.go(Routes.splashPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return StreamBuilder<MosqueModel?>(
      stream: sl<IMosqueRepository>().streamActiveMosque,
      builder: (context, snapshot) {
        final mosqueName = snapshot.data?.name ?? '';
        return ListenableBuilder(
          listenable: _drawerController,
          builder: (context, _) {
            return TvNavigationScope(
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
                  onSelectSection: (i) {
                    _drawerController.close();
                    setState(() => _sectionIndex = i);
                  },
                  onSignOut: _signOut,
                ),
                mainScreen: Scaffold(
                  appBar: SettingsAppBar(
                    sectionIndex: _sectionIndex,
                    mosqueName: mosqueName,
                    onMenuPressed: _drawerController.toggle,
                    popupMenuBuilder: (BuildContext context) => [
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
                  body: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: IndexedStack(
                        index: _sectionIndex,
                        sizing: StackFit.expand,
                        children: const [
                          GeneralSection(),
                          PrayerIqamaSection(),
                          ReligiousContentSection(),
                          DesignSection(),
                          AnnouncementSection(),
                          AlbumSection(),
                          AlertsSection(),
                          ProfileSection(),
                          AboutSection(),
                          UpdateSection(),
                          RecitationPage(),
                        ],
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
}
