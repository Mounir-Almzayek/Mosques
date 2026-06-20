import 'package:equatable/equatable.dart';

import '../../../core/enums/settings/mosque_text_list_kind.dart';
import '../../../core/utils/date_parse.dart';

/// A single religious-content item (hadith / verse / dua / dhikr) —
/// 1:1 with backend `ContentItemResponse`.
///
/// `kind` values match the backend: `hadith`, `ayah`/`verse`, `dua`,
/// `dhikr`/`adhkar`.
class ContentItem extends Equatable {
  final String id;
  final String kind;
  final String text;
  final String narrator;
  final String source;
  final bool isActive;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ContentItem({
    this.id = '',
    this.kind = '',
    this.text = '',
    this.narrator = '',
    this.source = '',
    this.isActive = true,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      narrator: json['narrator']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      isActive: json['isActive'] != false,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      createdAt: parseDateOrMillis(json['createdAt']),
      updatedAt: parseDateOrMillis(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'text': text,
        'narrator': narrator,
        'source': source,
        'isActive': isActive,
        'displayOrder': displayOrder,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Item shape inside a `PUT .../religious-content` group request
  /// (`ReligiousContentItemRequest`: uses `order`, no `kind`).
  Map<String, dynamic> toReligiousRequestItem() => {
        if (id.isNotEmpty) 'id': id,
        'text': text,
        'source': source,
        'narrator': narrator,
        'isActive': isActive,
        'order': displayOrder,
      };

  /// The canonical kind for a [MosqueTextListKind] when creating new items.
  static String kindFor(MosqueTextListKind kind) {
    switch (kind) {
      case MosqueTextListKind.hadith:
        return 'hadith';
      case MosqueTextListKind.verse:
        return 'ayah';
      case MosqueTextListKind.dua:
        return 'dua';
      case MosqueTextListKind.adhkar:
        return 'dhikr';
    }
  }

  ContentItem copyWith({
    String? id,
    String? kind,
    String? text,
    String? narrator,
    String? source,
    bool? isActive,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContentItem(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      text: text ?? this.text,
      narrator: narrator ?? this.narrator,
      source: source ?? this.source,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        kind,
        text,
        narrator,
        source,
        isActive,
        displayOrder,
        createdAt,
        updatedAt,
      ];
}
