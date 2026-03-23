import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';

/// Side navigation for settings: brand header + section shortcuts + sign out.
class SettingsDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectSection;
  final VoidCallback onSignOut;

  const SettingsDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelectSection,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget navTile({
      required int index,
      required IconData icon,
      required String label,
    }) {
      final selected = selectedIndex == index;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Material(
          color: selected
              ? scheme.primaryContainer.withValues(alpha: 0.65)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).pop();
              onSelectSection(index);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(Icons.chevron_right_rounded, color: scheme.onPrimaryContainer, size: 26),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final screenW = MediaQuery.sizeOf(context).width;
    final drawerWidth = math.min(420.0, screenW * 0.88);

    return Drawer(
      width: drawerWidth,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryStart,
                    AppColors.primary,
                    AppColors.primaryEnd,
                  ],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/logo.jpg',
                        height: 92,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.mosque_rounded,
                          size: 72,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.login_subtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.settings_drawer_tagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      color: AppColors.textOnPrimary.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
              child: Text(
                s.settings_navigate_sections,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: 15,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  navTile(index: 0, icon: Icons.manage_accounts_outlined, label: s.tab_general),
                  navTile(index: 1, icon: Icons.palette_outlined, label: s.tab_design),
                  navTile(index: 2, icon: Icons.schedule_outlined, label: s.tab_iqama),
                  navTile(index: 3, icon: Icons.menu_book_rounded, label: s.tab_hadith),
                  navTile(index: 4, icon: Icons.format_quote_rounded, label: s.tab_verses),
                  navTile(index: 5, icon: Icons.favorite_border_rounded, label: s.tab_duas),
                  navTile(index: 6, icon: Icons.psychology_outlined, label: s.tab_adhkar),
                  navTile(index: 7, icon: Icons.campaign_outlined, label: s.tab_announcements),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              minLeadingWidth: 40,
              leading: Icon(Icons.logout_rounded, color: scheme.error, size: 28),
              title: Text(
                s.sign_out,
                style: TextStyle(
                  color: scheme.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onSignOut();
              },
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
