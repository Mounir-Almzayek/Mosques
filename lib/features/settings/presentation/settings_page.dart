import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/repository/auth_repository.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../bloc/settings_bloc.dart';
import 'widgets/settings_drawer.dart';

import 'sections/general_section.dart';
import 'sections/design_section.dart';
import 'sections/iqama_section.dart';
import 'sections/mosque_text_list_section.dart';
import '../../../data/models/mosque_text_list_kind.dart';
import 'sections/announcement_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc()..add(LoadSettings()),
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
              context.read<SettingsBloc>().add(LoadSettings());
            },
          ),
          PopupMenuButton<String>(
            iconSize: 28,
            onSelected: (value) async {
              if (value == 'smart_screen') {
                // Navigate to Display (Smart screen) immediately.
                // We force display-mode override so it works even on smaller screens.
                await AuthRepository.setIsDisplayModeOverride(true);
                if (!context.mounted) return;
                context.go(Routes.displayPath);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'smart_screen',
                  // This menu behaves like a "go to smart screen" action.
                  child: Text(s.enable_smart_screen),
                ),
              ];
            },
          ),
        ],
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listenWhen: (prev, curr) {
          if (curr is SettingsSaving) return true;
          if (curr is SettingsError) return true;
          if (curr is SettingsLoaded && prev is SettingsSaving) return true;
          return false;
        },
        listener: (context, state) {
          if (state is SettingsSaving) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).saving)),
            );
          } else if (state is SettingsLoaded) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).saved_successfully)),
            );
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsInitial || state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final mosque = state.request.mosque;
          if (state is SettingsError && mosque == null) {
            return Center(child: Text(state.message));
          }

          if (mosque == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return IndexedStack(
            index: _sectionIndex,
            sizing: StackFit.expand,
            children: [
              GeneralSection(mosque: mosque),
              DesignSection(mosque: mosque),
              IqamaSection(mosque: mosque),
              MosqueTextListSection(mosque: mosque, kind: MosqueTextListKind.hadith),
              MosqueTextListSection(mosque: mosque, kind: MosqueTextListKind.verse),
              MosqueTextListSection(mosque: mosque, kind: MosqueTextListKind.dua),
              MosqueTextListSection(mosque: mosque, kind: MosqueTextListKind.adhkar),
              AnnouncementSection(mosque: mosque),
            ],
          );
        },
      ),
    );
  }
}
