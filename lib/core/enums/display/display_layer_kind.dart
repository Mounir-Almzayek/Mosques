/// Priority-based display layers. Lower index = higher priority.
/// Only one layer is visible at a time; the highest-priority active layer wins.
enum DisplayLayerKind {
  alert,
  recitation,
  photoStudio,
  iqamaAdhan,
  religious,
  prayerTimes;

  bool get isFullscreen => this != prayerTimes;
}
