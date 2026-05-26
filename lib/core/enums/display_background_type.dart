
/// Types of backgrounds supported by the display screen.
enum DisplayBackgroundType {
  image,
  color,
  remoteUrl;

  String get code {
    if (this == remoteUrl) return 'remote_url';
    return name;
  }

  static DisplayBackgroundType fromCode(String? code) {
    if (code == 'color') return DisplayBackgroundType.color;
    if (code == 'remote_url' || code == 'remoteUrl') return DisplayBackgroundType.remoteUrl;
    return DisplayBackgroundType.image;
  }
}
