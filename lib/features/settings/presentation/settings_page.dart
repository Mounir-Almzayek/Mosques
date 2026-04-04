import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/app_mode.dart';
import '../../auth/repository/auth_repository.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/enums/settings/mosque_text_list_kind.dart';
import '../../../core/widgets/feedback/unified_snackbar.dart';
import '../bloc/settings/settings_bloc.dart';
import 'widgets/common/common_widgets.dart';

import 'sections/general_section.dart';
import 'sections/design_section.dart';
import 'sections/iqama_section.dart';
import 'sections/mosque_text_list_section.dart';
import 'sections/announcement_section.dart';
import 'sections/alerts_section.dart';
import 'sections/profile_section.dart';
import 'sections/about_section.dart';
import 'sections/update_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc()..add(const LoadSettings()),
      child: const SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _sectionIndex = 0;

  void _signOut() async {
    await AuthRepository.logout();
    if (mounted) {
      context.go(Routes.splashPath);
    }
  }

  String _titleForIndex(S s, int i) {
    switch (i) {
      case 0:
        return s.tab_general;
      case 1:
        return s.tab_design;
      case 2:
        return s.tab_iqama;
      case 3:
        return s.tab_hadith;
      case 4:
        return s.tab_verses;
      case 5:
        return s.tab_duas;
      case 6:
        return s.tab_adhkar;
      case 7:
        return s.tab_announcements;
      case 8:
        return s.tab_alerts;
      case 9:
        return s.tab_profile;
      case 10:
        return s.tab_about;
      case 11:
        return s.tab_update;
      default:
        return s.settings_title;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      drawer: SettingsDrawer(
        selectedIndex: _sectionIndex,
        onSelectSection: (i) => setState(() => _sectionIndex = i),
        onSignOut: _signOut,
      ),
      appBar: AppBar(
        toolbarHeight: 72,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 23,
          fontWeight: FontWeight.w600,
        ),
        title: Text(_titleForIndex(s, _sectionIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            iconSize: 28,
            tooltip: s.refresh,
            onPressed: () {
              context.read<SettingsBloc>().add(const LoadSettings());
            },
          ),
          PopupMenuButton<String>(
            iconSize: 28,
            onSelected: (value) async {
              if (value == 'smart_screen') {
                await AuthRepository.setAppModeOverride(AppMode.deviceDisplay);
                if (!context.mounted) return;
                context.go(Routes.displayPath);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'smart_screen',
                  child: Text(s.enable_smart_screen),
                ),
              ];
            },
          ),
        ],
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listenWhen: (prev, curr) {
          if (curr.isSaving && !prev.isSaving) return true;
          if (curr.error != null && prev.error == null) return true;
          if (!curr.isSaving && prev.isSaving && curr.error == null)
            return true;
          return false;
        },
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
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final mosque = state.request.mosque;
          if (state.error != null && mosque == null) {
            return Center(child: Text(state.error!));
          }

          if (mosque == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return IndexedStack(
            index: _sectionIndex,
            sizing: StackFit.expand,
            children: [
              GeneralSection(mosque: mosque),
              DesignSection(),
              IqamaSection(mosque: mosque),
              MosqueTextListSection(
                mosque: mosque,
                kind: MosqueTextListKind.hadith,
              ),
              MosqueTextListSection(
                mosque: mosque,
                kind: MosqueTextListKind.verse,
              ),
              MosqueTextListSection(
                mosque: mosque,
                kind: MosqueTextListKind.dua,
              ),
              MosqueTextListSection(
                mosque: mosque,
                kind: MosqueTextListKind.adhkar,
              ),
              AnnouncementSection(mosque: mosque),
              AlertsSection(mosque: mosque),
              const ProfileSection(),
              const AboutSection(),
              const UpdateSection(),
            ],
          );
        },
      ),
    );
  }
}
