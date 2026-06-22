import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/app_language.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../language/bloc/language/language_bloc.dart';
import '../../notifications/bloc/notifications_bloc.dart';

/// Beautiful gradient AppBar for the settings screen.
class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int sectionIndex;
  final String mosqueName;
  final bool showRecitation;
  final VoidCallback onMenuPressed;
  final VoidCallback onNotificationsPressed;
  final List<PopupMenuEntry<String>> Function(BuildContext) popupMenuBuilder;
  final void Function(String) onPopupMenuSelected;

  const SettingsAppBar({
    super.key,
    required this.sectionIndex,
    required this.mosqueName,
    this.showRecitation = false,
    required this.onMenuPressed,
    required this.onNotificationsPressed,
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
    final popupItems = popupMenuBuilder(context);

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
                BlocBuilder<LanguageBloc, LanguageState>(
                  builder: (context, langState) {
                    return PopupMenuButton<AppLanguage>(
                      tooltip: s.settings_language,
                      icon: const Icon(
                        Icons.translate_rounded,
                        color: Colors.white,
                        size: 23,
                      ),
                      onSelected: (language) => context
                          .read<LanguageBloc>()
                          .add(ChangeLanguage(language)),
                      itemBuilder: (_) => AppLanguage.values
                          .map(
                            (language) => PopupMenuItem<AppLanguage>(
                              value: language,
                              child: Row(
                                children: [
                                  Icon(
                                    langState.language == language
                                        ? Icons.check_rounded
                                        : Icons.language_rounded,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(language.name),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                BlocBuilder<NotificationsBloc, NotificationsState>(
                  builder: (context, state) {
                    final count = state.unreadCount;
                    return IconButton(
                      tooltip: s.tab_notifications,
                      onPressed: onNotificationsPressed,
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          if (count > 0)
                            PositionedDirectional(
                              end: -8,
                              top: -8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  count > 9 ? '+9' : count.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                if (popupItems.isNotEmpty)
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onSelected: onPopupMenuSelected,
                    itemBuilder: (_) => popupItems,
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _titleForIndex(S s, int i) {
    final titles = [
      s.tab_general,
      s.tab_notifications,
      s.tab_mosque_info,
      s.tab_prayer_iqama,
      s.tab_religious_content,
      s.tab_design,
      s.tab_announcements,
      s.tab_album,
      s.tab_alerts,
      if (showRecitation) s.recitation_tracking_title,
      s.tab_profile,
      s.tab_about,
      s.tab_update,
    ];
    return i >= 0 && i < titles.length ? titles[i] : s.settings_title;
  }

  IconData _iconForIndex(int i) {
    final icons = [
      Icons.dashboard_outlined,
      Icons.notifications_none_rounded,
      Icons.mosque_outlined,
      Icons.access_time_outlined,
      Icons.auto_stories_outlined,
      Icons.palette_outlined,
      Icons.campaign_outlined,
      Icons.photo_library_outlined,
      Icons.notification_important_outlined,
      if (showRecitation) Icons.mic_rounded,
      Icons.person_outlined,
      Icons.info_outlined,
      Icons.system_update_outlined,
    ];
    return i >= 0 && i < icons.length ? icons[i] : Icons.settings_outlined;
  }
}
