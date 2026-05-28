import 'package:flutter/material.dart';
import '../../../../core/l10n/generated/l10n.dart';

/// Beautiful gradient AppBar for the settings screen.
class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int sectionIndex;
  final String mosqueName;
  final VoidCallback onMenuPressed;
  final List<PopupMenuEntry<String>> Function(BuildContext) popupMenuBuilder;
  final void Function(String) onPopupMenuSelected;

  const SettingsAppBar({
    super.key,
    required this.sectionIndex,
    required this.mosqueName,
    required this.onMenuPressed,
    required this.popupMenuBuilder,
    required this.onPopupMenuSelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  static const _gradient = LinearGradient(
    colors: [Color(0xFF1A3C34), Color(0xFF2E7D52)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final title = _titleForIndex(s, sectionIndex);
    final icon = _iconForIndex(sectionIndex);

    return Container(
      decoration: BoxDecoration(
        gradient: _gradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 80,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: onMenuPressed,
                ),
                const SizedBox(width: 4),
                Icon(icon, color: Colors.white70, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (mosqueName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          mosqueName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onSelected: onPopupMenuSelected,
                  itemBuilder: popupMenuBuilder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _titleForIndex(S s, int i) {
    switch (i) {
      case 0:
        return s.tab_general;
      case 1:
        return s.tab_prayer_iqama;
      case 2:
        return s.tab_religious_content;
      case 3:
        return s.tab_design;
      case 4:
        return s.tab_announcements;
      case 5:
        return s.tab_album;
      case 6:
        return s.tab_alerts;
      case 7:
        return s.tab_profile;
      case 8:
        return s.tab_about;
      case 9:
        return s.tab_update;
      default:
        return s.settings_title;
    }
  }

  IconData _iconForIndex(int i) {
    switch (i) {
      case 0:
        return Icons.mosque_outlined;
      case 1:
        return Icons.access_time_outlined;
      case 2:
        return Icons.auto_stories_outlined;
      case 3:
        return Icons.palette_outlined;
      case 4:
        return Icons.campaign_outlined;
      case 5:
        return Icons.photo_library_outlined;
      case 6:
        return Icons.notification_important_outlined;
      case 7:
        return Icons.person_outlined;
      case 8:
        return Icons.info_outlined;
      case 9:
        return Icons.system_update_outlined;
      default:
        return Icons.settings_outlined;
    }
  }
}
