import 'package:equatable/equatable.dart';

import 'about_section_model.dart';

class AboutCategoryModel extends Equatable {
  final String title;
  final List<AboutSectionModel> sections;

  const AboutCategoryModel({
    required this.title,
    required this.sections,
  });

  factory AboutCategoryModel.fromMap(Map<String, dynamic> map) {
    return AboutCategoryModel(
      title: map['title'] ?? '',
      sections: (map['sections'] as List? ?? [])
          .map((s) => AboutSectionModel.fromMap(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'sections': sections.map((s) => s.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [title, sections];
}

