import 'package:equatable/equatable.dart';
import '../../../core/enums/about/about_section_type.dart';
import '../../../core/enums/about/about_section_weight.dart';

export '../../../core/enums/about/about_section_type.dart';
export '../../../core/enums/about/about_section_weight.dart';

class AboutSectionModel extends Equatable {
  final AboutSectionType type;
  final String content;
  final double fontSize;
  final AboutSectionWeight fontWeight;

  const AboutSectionModel({
    required this.type,
    required this.content,
    this.fontSize = 14.0,
    this.fontWeight = AboutSectionWeight.thin,
  });

  factory AboutSectionModel.fromMap(Map<String, dynamic> map) {
    return AboutSectionModel(
      type: AboutSectionType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'text'),
        orElse: () => AboutSectionType.text,
      ),
      content: map['content'] ?? '',
      fontSize: (map['font_size'] ?? 14.0).toDouble(),
      fontWeight: AboutSectionWeight.values.firstWhere(
        (e) => e.name == (map['font_weight'] ?? 'thin'),
        orElse: () => AboutSectionWeight.thin,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'content': content,
      'font_size': fontSize,
      'font_weight': fontWeight.name,
    };
  }

  @override
  List<Object?> get props => [type, content, fontSize, fontWeight];
}
