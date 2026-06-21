import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/utils/version_helper.dart';
import '../../../../core/widgets/media/media_widgets.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../data/repositories/interfaces/app_config_repository_interface.dart';
import 'drawer_nav_tile.dart';

class SettingsZoomDrawerContent extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectSection;
  final VoidCallback onSignOut;
  final bool isOpen;
  final bool showRecitation;

  const SettingsZoomDrawerContent({
    super.key,
    required this.selectedIndex,
    required this.onSelectSection,
    required this.onSignOut,
    required this.isOpen,
    this.showRecitation = false,
  });

  @override
  State<SettingsZoomDrawerContent> createState() =>
      _SettingsZoomDrawerContentState();
}

class _SettingsZoomDrawerContentState extends State<SettingsZoomDrawerContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _slideAnimations;

  static const int _maxItemCount = 11;
  int get _itemCount => widget.showRecitation ? 11 : 10;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimations = List.generate(_maxItemCount, (i) {
      final start = i * 0.05;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
    _slideAnimations = List.generate(_maxItemCount, (i) {
      final start = i * 0.05;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(-0.3, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    if (widget.isOpen) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SettingsZoomDrawerContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isOpen && widget.isOpen) {
      _controller.forward(from: 0);
    } else if (oldWidget.isOpen && !widget.isOpen) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    final navItems = [
      (Icons.mosque_outlined, s.tab_general),
      (Icons.access_time_outlined, s.tab_prayer_iqama),
      (Icons.menu_book_rounded, s.tab_religious_content),
      (Icons.palette_outlined, s.tab_design),
      (Icons.campaign_outlined, s.tab_announcements),
      (Icons.photo_library_outlined, s.tab_album),
      (Icons.emergency_share_outlined, s.tab_alerts),
      if (widget.showRecitation)
        (Icons.mic_rounded, s.recitation_tracking_title),
      (Icons.person_outline_rounded, s.tab_profile),
      (Icons.info_outline_rounded, s.tab_about),
      (Icons.system_update_rounded, s.tab_update),
    ];

    return Material(
      color: const Color(0xFF1A2F2E),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: OptimizedImage.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.mosque_rounded,
                              color: Color(0xFF384C4B),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.login_subtitle,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          s.settings_drawer_tagline,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.65),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Section label
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
              child: Text(
                s.settings_navigate_sections,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.45),
                  letterSpacing: 0.8,
                ),
              ),
            ),
            // Nav items
            Expanded(
              child: ListView.builder(
                key: ValueKey(widget.isOpen),
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: _itemCount,
                itemBuilder: (context, i) {
                  return FadeTransition(
                    opacity: _fadeAnimations[i],
                    child: SlideTransition(
                      position: _slideAnimations[i],
                      child: DrawerNavTile(
                        index: i,
                        selectedIndex: widget.selectedIndex,
                        icon: navItems[i].$1,
                        label: navItems[i].$2,
                        autofocus: widget.isOpen && i == widget.selectedIndex,
                        onTap: () => widget.onSelectSection(i),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Footer
            Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 0,
              ),
              minLeadingWidth: 32,
              leading: Icon(
                Icons.support_agent_rounded,
                color: Colors.green.shade400,
                size: 26,
              ),
              title: Text(
                s.contact_developers,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade400,
                ),
              ),
              onTap: () async {
                final appSettings = await sl<IAppConfigRepository>()
                    .getAppConfig();
                final phone = appSettings?.supportPhone ?? '';
                if (phone.isNotEmpty) {
                  final Uri whatsappUrl = Uri.parse('https://wa.me/$phone');
                  if (await canLaunchUrl(whatsappUrl)) {
                    await launchUrl(
                      whatsappUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                }
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 0,
              ),
              minLeadingWidth: 32,
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
                size: 26,
              ),
              title: Text(
                s.sign_out,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
              onTap: widget.onSignOut,
            ),
            FutureBuilder<String>(
              future: VersionHelper.getCurrentVersion(),
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(
                      'V ${snapshot.data ?? '...'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
