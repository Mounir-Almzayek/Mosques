import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/platform_announcements/settings_announcement_model.dart';
import 'settings_announcement_slide.dart';
import 'settings_announcement_slider_dots.dart';

class SettingsAnnouncementsSlider extends StatefulWidget {
  const SettingsAnnouncementsSlider({super.key, required this.announcements});

  final List<SettingsAnnouncementModel> announcements;

  @override
  State<SettingsAnnouncementsSlider> createState() =>
      _SettingsAnnouncementsSliderState();
}

class _SettingsAnnouncementsSliderState
    extends State<SettingsAnnouncementsSlider> {
  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant SettingsAnnouncementsSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.announcements.length != widget.announcements.length) {
      _index = 0;
      if (_controller.hasClients) {
        _controller.jumpToPage(0);
      }
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.announcements.length < 2) return;

    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % widget.announcements.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.announcements.isEmpty) return const SizedBox.shrink();

    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: s.settings_app_announcements_title,
      child: Container(
        height: 178,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: widget.announcements.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  return SettingsAnnouncementSlide(
                    announcement: widget.announcements[index],
                  );
                },
              ),
              PositionedDirectional(
                start: 16,
                end: 16,
                top: 14,
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.settings_app_announcements_title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.announcements.length > 1)
                PositionedDirectional(
                  end: 16,
                  bottom: 14,
                  child: SettingsAnnouncementSliderDots(
                    count: widget.announcements.length,
                    currentIndex: _index,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
