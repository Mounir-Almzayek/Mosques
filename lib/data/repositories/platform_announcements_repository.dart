import '../../core/cache/cache.dart';
import '../datasources/mosque_remote_data_source.dart';
import '../models/mosque/mosque_bootstrap.dart';
import '../models/platform_announcements/settings_announcement_model.dart';
import 'interfaces/platform_announcements_repository_interface.dart';

/// Platform-wide announcements, sourced from the mosque bootstrap's
/// `platformAnnouncements` list (the backend folds them into the snapshot).
class PlatformAnnouncementsRepository
    implements IPlatformAnnouncementsRepository {
  final MosqueRemoteDataSource _dataSource;
  final String? Function() _getActiveMosqueId;
  final JsonCache<List<Announcement>> _displayCache;
  final CacheFirstLoader<List<Announcement>> _displayLoader;
  final CacheFirstLoader<List<SettingsAnnouncementModel>> _settingsLoader;

  PlatformAnnouncementsRepository({
    required MosqueRemoteDataSource dataSource,
    required String? Function() getActiveMosqueId,
    required JsonCache<List<Announcement>> displayCache,
    required JsonCache<List<SettingsAnnouncementModel>> settingsCache,
  })  : _dataSource = dataSource,
        _getActiveMosqueId = getActiveMosqueId,
        _displayCache = displayCache,
        _displayLoader = CacheFirstLoader(displayCache),
        _settingsLoader = CacheFirstLoader(settingsCache);

  String? get _activeId {
    final id = _getActiveMosqueId();
    return (id == null || id.isEmpty) ? null : id;
  }

  bool _isInWindow(Announcement a, DateTime now) => a.isActiveAt(now);

  List<Announcement> _displayList(MosqueBootstrap? b, DateTime now) {
    if (b == null) return const [];
    return b.platformAnnouncements
        .where((a) => a.audience == 'display' && _isInWindow(a, now))
        .toList()
      ..sort((x, y) => x.displayOrder.compareTo(y.displayOrder));
  }

  List<SettingsAnnouncementModel> _settingsList(MosqueBootstrap? b) {
    if (b == null) return const [];
    final now = DateTime.now();
    return b.platformAnnouncements
        .where((a) => a.audience == 'imam')
        .map(_toSettings)
        .where((s) => s.isVisibleAt(now))
        .toList()
      ..sort((x, y) => x.order.compareTo(y.order));
  }

  SettingsAnnouncementModel _toSettings(Announcement a) {
    return SettingsAnnouncementModel(
      id: a.id,
      title: a.title,
      body: (a.subtitle?.trim().isEmpty ?? true) ? null : a.subtitle!.trim(),
      imageUrl: null,
      linkUrl: (a.qrCodeUrl?.trim().isEmpty ?? true) ? null : a.qrCodeUrl!.trim(),
      isActive: a.isActive,
      order: a.displayOrder,
      startDate: a.startAt,
      endDate: a.endAt,
    );
  }

  Stream<List<Announcement>?> _displayRemoteStream() {
    final id = _activeId;
    if (id == null) return Stream.value(const []);
    return _dataSource
        .watchBootstrap(id)
        .map((b) => _displayList(b, DateTime.now()));
  }

  Stream<List<SettingsAnnouncementModel>?> _settingsRemoteStream() {
    final id = _activeId;
    if (id == null) return Stream.value(const []);
    return _dataSource.watchBootstrap(id).map(_settingsList);
  }

  @override
  Stream<List<Announcement>> watchActiveForDisplay() =>
      _displayLoader.stream(remote: _displayRemoteStream).map((v) {
        final now = DateTime.now();
        return (v ?? const <Announcement>[])
            .where((a) => _isInWindow(a, now))
            .toList();
      });

  @override
  Stream<List<SettingsAnnouncementModel>> watchSettingsAnnouncements() =>
      _settingsLoader.stream(remote: _settingsRemoteStream).map((v) {
        final now = DateTime.now();
        return (v ?? const <SettingsAnnouncementModel>[])
            .where((a) => a.isVisibleAt(now))
            .toList();
      });

  @override
  Future<List<Announcement>> fetchActiveForDisplayFromServer() async {
    try {
      final id = _activeId;
      if (id == null) return const [];
      final b = await _dataSource.fetchBootstrap(id);
      final list = _displayList(b, DateTime.now());
      await _displayCache.save(list);
      return list;
    } catch (_) {
      return (await _displayCache.read())?.value ?? const [];
    }
  }
}
