
/// Types of backgrounds supported by the display screen.
enum DisplayBackgroundType {
  image,
  color;

  String get code => name;

  static DisplayBackgroundType fromCode(String? code) {
    if (code == 'color') return DisplayBackgroundType.color;
    return DisplayBackgroundType.image;
  }
}
