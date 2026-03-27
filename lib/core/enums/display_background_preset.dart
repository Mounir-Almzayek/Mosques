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
  mosqueDisplay06(
    'mosque_display_06',
    'assets/display_backgrounds/mosque_display_06.jpg',
  ),
  mosqueDisplay07(
    'mosque_display_07',
    'assets/display_backgrounds/mosque_display_07.jpg',
  ),
  mosqueDisplay08(
    'mosque_display_08',
    'assets/display_backgrounds/mosque_display_08.jpg',
  ),
  mosqueDisplay09(
    'mosque_display_09',
    'assets/display_backgrounds/mosque_display_09.jpg',
  ),
  mosqueDisplay10(
    'mosque_display_10',
    'assets/display_backgrounds/mosque_display_10.jpg',
  );

  const DisplayBackgroundPreset(this.storageId, this.assetPath);

  final String storageId;
  final String assetPath;

  /// Explicitly set fallback = first image (mosque_display_primary)
  static const String defaultStorageId = 'mosque_display_primary';

  static DisplayBackgroundPreset fromStorageId(String? raw) {
    final v = raw?.trim() ?? '';
    // Prevent logo or invalid ids from breaking the background display
    for (final p in DisplayBackgroundPreset.values) {
      if (p.storageId == v) return p;
    }
    // Final fallback to primary
    return DisplayBackgroundPreset.mosqueDisplayPrimary;
  }

  static String normalizeStoredId(String? raw) => fromStorageId(raw).storageId;
}
