/// Preset display backgrounds (bundled assets). [storageId] is stored in Firestore
/// under `design_settings.background_value`.
enum DisplayBackgroundPreset {
  mosqueDisplayPrimary(
    'mosque_display_primary',
    'assets/display_backgrounds/mosque_display_primary.jpg',
  ),
  mosqueDisplay01(
    'mosque_display_01',
    'assets/display_backgrounds/mosque_display_01.jpg',
  ),
  mosqueDisplay02(
    'mosque_display_02',
    'assets/display_backgrounds/mosque_display_02.jpg',
  ),
  mosqueDisplay03(
    'mosque_display_03',
    'assets/display_backgrounds/mosque_display_03.jpg',
  ),
  mosqueDisplay04(
    'mosque_display_04',
    'assets/display_backgrounds/mosque_display_04.jpg',
  ),
  mosqueDisplay05(
    'mosque_display_05',
    'assets/display_backgrounds/mosque_display_05.jpg',
  ),
  mosqueDisplayBrand('mosque_display_brand', 'assets/logo.jpg');

  const DisplayBackgroundPreset(this.storageId, this.assetPath);

  final String storageId;
  final String assetPath;

  static const String defaultStorageId = 'mosque_display_primary';

  static DisplayBackgroundPreset fromStorageId(String? raw) {
    final v = raw?.trim() ?? '';
    if (v.startsWith('http')) {
      return DisplayBackgroundPreset.mosqueDisplayPrimary;
    }
    if (v.isEmpty) {
      return DisplayBackgroundPreset.mosqueDisplayPrimary;
    }
    for (final p in DisplayBackgroundPreset.values) {
      if (p.storageId == v) return p;
    }
    if (v.contains('background.jpg') || v == 'assets/background.jpg') {
      return DisplayBackgroundPreset.mosqueDisplayPrimary;
    }
    return DisplayBackgroundPreset.mosqueDisplayPrimary;
  }

  static String normalizeStoredId(String? raw) => fromStorageId(raw).storageId;
}
