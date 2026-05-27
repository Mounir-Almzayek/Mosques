
/// Types of backgrounds supported by the display screen.
enum DisplayBackgroundType {
  image,
  color,
  album;

  String get code {
    if (this == album) return 'album';
    return name;
  }

  static DisplayBackgroundType fromCode(String? code) {
    if (code == 'color') return DisplayBackgroundType.color;
    if (code == 'album' || code == 'remote_url' || code == 'remoteUrl') {
      return DisplayBackgroundType.album;
    }
    return DisplayBackgroundType.image;
  }
}
