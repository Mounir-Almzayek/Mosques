import 'package:equatable/equatable.dart';

/// Predefined list of Google Fonts popular for mosque displays.
class FontPreset extends Equatable {
  final String name;
  final String displayName;

  const FontPreset({required this.name, required this.displayName});

  @override
  List<Object?> get props => [name, displayName];

  static const List<FontPreset> values = [
    FontPreset(name: 'Beiruti', displayName: 'بيروتي (Beiruti)'),
    FontPreset(name: 'Amiri', displayName: 'أميري (Amiri)'),
    FontPreset(name: 'Cairo', displayName: 'كاييرو (Cairo)'),
    FontPreset(name: 'Tajawal', displayName: 'تجول (Tajawal)'),
    FontPreset(name: 'Almarai', displayName: 'المراعي (Almarai)'),
    FontPreset(name: 'Changa', displayName: 'شانجا (Changa)'),
    FontPreset(name: 'Lemonada', displayName: 'ليموندة (Lemonada)'),
    FontPreset(name: 'El Messiri', displayName: 'المسيري (El Messiri)'),
    FontPreset(name: 'Mada', displayName: 'مدى (Mada)'),
    FontPreset(name: 'Reem Kufi', displayName: 'ريم كوفي (Reem Kufi)'),
    FontPreset(name: 'Harmattan', displayName: 'هارمتان (Harmattan)'),
    FontPreset(name: 'Lalezar', displayName: 'لاليزار (Lalezar)'),
    FontPreset(name: 'Scheherazade New', displayName: 'شهرزاد (Scheherazade)'),
    FontPreset(name: 'Areiru', displayName: 'أريرو (Areiru)'),
  ];
}
