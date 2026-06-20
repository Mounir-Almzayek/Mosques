import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../core/enums/display/display_layer_kind.dart';
import '../../../core/utils/prayer_display_phase.dart';
import '../../../data/models/display/display_layer_state.dart';
import '../../../data/models/mosque/announcement.dart';

class DisplayLayerController extends ChangeNotifier {
  DisplayLayerState _state = const DisplayLayerState();
  DisplayLayerState get state => _state;

  List<Announcement> _alerts = [];
  PrayerDisplayPhase? _prayerPhase;
  bool _recitationActive = false;
  bool _photoStudioActive = false;
  String? _photoStudioUrl;

  Timer? _religiousTimer;
  bool _religiousVisible = false;
  int _religiousWaitSeconds = 120;
  int _religiousDisplaySeconds = 30;
  int _religiousSlideIndex = 0;
  int get religiousSlideIndex => _religiousSlideIndex;
  bool get religiousVisible => _religiousVisible;

  String? get photoStudioUrl => _photoStudioUrl;

  void configure({
    required int religiousWaitSeconds,
    required int religiousDisplaySeconds,
  }) {
    final changed =
        _religiousWaitSeconds != religiousWaitSeconds ||
        _religiousDisplaySeconds != religiousDisplaySeconds;
    _religiousWaitSeconds = religiousWaitSeconds;
    _religiousDisplaySeconds = religiousDisplaySeconds;
    if (changed) _restartReligiousTimer();
  }

  void updateAlerts(List<Announcement> alerts) {
    _alerts = alerts;
    _resolve();
  }

  void updatePrayerPhase(PrayerDisplayPhase phase) {
    _prayerPhase = phase;
    _resolve();
  }

  void updateRecitationActive(bool active) {
    if (_recitationActive == active) return;
    _recitationActive = active;
    _resolve();
  }

  /// Updates album image state from the mosque's published album fields.
  void updateAlbumImage({
    required String? publishedUrl,
    required DateTime? publishedAt,
    required int durationSeconds,
  }) {
    if (publishedUrl != null &&
        publishedUrl.isNotEmpty &&
        publishedAt != null) {
      final expiry = publishedAt.add(Duration(seconds: durationSeconds));
      final now = DateTime.now();
      if (now.isBefore(expiry)) {
        _photoStudioActive = true;
        _photoStudioUrl = publishedUrl;
        _resolve();
        return;
      }
    }
    _photoStudioActive = false;
    _photoStudioUrl = null;
    _resolve();
  }

  void showPhotoStudio(String imageUrl) {
    _photoStudioActive = true;
    _photoStudioUrl = imageUrl;
    _resolve();
  }

  void hidePhotoStudio() {
    _photoStudioActive = false;
    _photoStudioUrl = null;
    _resolve();
  }

  void startReligiousCycle() {
    _restartReligiousTimer();
  }

  void _restartReligiousTimer() {
    _religiousTimer?.cancel();
    _religiousVisible = false;
    _scheduleReligiousWait();
    _resolve();
  }

  void _scheduleReligiousWait() {
    _religiousTimer?.cancel();
    _religiousTimer = Timer(Duration(seconds: _religiousWaitSeconds), () {
      _religiousVisible = true;
      _religiousSlideIndex++;
      _resolve();
      _scheduleReligiousDisplay();
    });
  }

  void _scheduleReligiousDisplay() {
    _religiousTimer?.cancel();
    _religiousTimer = Timer(Duration(seconds: _religiousDisplaySeconds), () {
      _religiousVisible = false;
      _resolve();
      _scheduleReligiousWait();
    });
  }

  Announcement? get activeAlert {
    if (_alerts.isEmpty) return null;
    final now = DateTime.now();
    for (final a in _alerts) {
      if (a.isActiveAt(now)) return a;
    }
    return null;
  }

  void _resolve() {
    final previous = _state.activeLayer;
    DisplayLayerKind next;

    if (activeAlert != null) {
      next = DisplayLayerKind.alert;
    } else if (_recitationActive) {
      next = DisplayLayerKind.recitation;
    } else if (_photoStudioActive) {
      next = DisplayLayerKind.photoStudio;
    } else if (_isIqamaAdhanActive()) {
      next = DisplayLayerKind.iqamaAdhan;
    } else if (_religiousVisible) {
      next = DisplayLayerKind.religious;
    } else {
      next = DisplayLayerKind.prayerTimes;
    }

    if (next != previous) {
      _state = DisplayLayerState(activeLayer: next, previousLayer: previous);
      notifyListeners();
    }
  }

  bool _isIqamaAdhanActive() {
    if (_prayerPhase == null) return false;
    switch (_prayerPhase!.kind) {
      case PrayerDisplayPhaseKind.preAdhan:
      case PrayerDisplayPhaseKind.iqama:
      case PrayerDisplayPhaseKind.adhanMoment:
        return true;
      case PrayerDisplayPhaseKind.graceAfterIqama:
      case PrayerDisplayPhaseKind.nextAdhan:
        return false;
    }
  }

  @override
  void dispose() {
    _religiousTimer?.cancel();
    super.dispose();
  }
}
