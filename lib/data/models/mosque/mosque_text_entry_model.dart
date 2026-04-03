import 'package:equatable/equatable.dart';

/// نص قابل للعرض والتدوير (حديث، آية، دعاء، ذكر) — نفس الحقول لكل الأنواع.
class MosqueTextEntryModel extends Equatable {
  final String id;
  final String narrator;
  final String text;
  final String source;
  final bool isActive;
  final int order;

  const MosqueTextEntryModel({
    required this.id,
    required this.narrator,
    required this.text,
    required this.source,
    this.isActive = true,
    this.order = 0,
  });

  factory MosqueTextEntryModel.fromMap(Map<String, dynamic> map, String id) {
    return MosqueTextEntryModel(
      id: id,
      narrator: map['narrator'] ?? '',
      text: map['text'] ?? '',
      source: map['source'] ?? '',
      isActive: map['is_active'] ?? true,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'narrator': narrator,
      'text': text,
      'source': source,
      'is_active': isActive,
      'order': order,
    };
  }

  MosqueTextEntryModel copyWith({
    String? id,
    String? narrator,
    String? text,
    String? source,
    bool? isActive,
    int? order,
  }) {
    return MosqueTextEntryModel(
      id: id ?? this.id,
      narrator: narrator ?? this.narrator,
      text: text ?? this.text,
      source: source ?? this.source,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, narrator, text, source, isActive, order];
}
