import 'package:flutter/painting.dart';

/// Ordered list of album-image fit options the user can choose at publish time.
/// Stored on the mosque as a string name; rendered via [boxFitFromName].
const List<String> kAlbumFitNames = [
  'contain',
  'cover',
  'fill',
  'fitWidth',
  'fitHeight',
];

/// Maps a stored fit name to a Flutter [BoxFit]. Unknown values fall back to
/// [BoxFit.contain] so a missing/legacy field never breaks rendering.
BoxFit boxFitFromName(String? name) {
  switch (name) {
    case 'cover':
      return BoxFit.cover;
    case 'fill':
      return BoxFit.fill;
    case 'fitWidth':
      return BoxFit.fitWidth;
    case 'fitHeight':
      return BoxFit.fitHeight;
    case 'contain':
    default:
      return BoxFit.contain;
  }
}
