import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../core/utils/firestore_date_parse.dart';

class AnnouncementModel extends Equatable {
  final String id;
  final String title;
  final String? subtitle;
  final DateTime startDate;
  final DateTime endDate;
  final String? qrCodeUrl;
  final bool isActive;
  final int order;

  const AnnouncementModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.startDate,
    required this.endDate,
    this.qrCodeUrl,
    this.isActive = true,
    this.order = 0,
  });

  /// Deterministic id for legacy data where `id` wasn't stored
  /// inside the embedded `mosque_ads` array.
  static String _fallbackId({
    required String title,
    String? subtitle,
    required DateTime startDate,
    required DateTime endDate,
    String? qrCodeUrl,
    required int order,
  }) {
    return [
      title.trim(),
      (subtitle ?? '').trim(),
      startDate.millisecondsSinceEpoch,
      endDate.millisecondsSinceEpoch,
      (qrCodeUrl ?? '').trim(),
      order,
    ].join('|');
  }

  static bool _parseIsActive(dynamic raw) {
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    if (raw is String) {
      final v = raw.trim().toLowerCase();
      if (v == 'true' || v == '1' || v == 'yes') return true;
      if (v == 'false' || v == '0' || v == 'no') return false;
    }
    return true;
  }

  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String id) {
    final title = (map['title'] ?? '').toString();
    final subtitle = map['subtitle']?.toString();
    final startDate = parseFirestoreOrMillis(map['start_date']) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final endDate = parseFirestoreOrMillis(map['end_date']) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final qrCodeUrl = map['qr_code_url']?.toString();
    final isActive = _parseIsActive(map['is_active']);

    final orderRaw = map['order'] ?? 0;
    final order = orderRaw is int
        ? orderRaw
        : (orderRaw is num ? orderRaw.toInt() : 0);

    final resolvedId = id.isNotEmpty
        ? id
        : _fallbackId(
            title: title,
            subtitle: subtitle,
            startDate: startDate,
            endDate: endDate,
            qrCodeUrl: qrCodeUrl,
            order: order,
          );

    return AnnouncementModel(
      id: resolvedId,
      title: title,
      subtitle: subtitle?.trim().isEmpty == true ? null : subtitle,
      startDate: startDate,
      endDate: endDate,
      qrCodeUrl: qrCodeUrl?.trim().isEmpty == true ? null : qrCodeUrl,
      isActive: isActive,
      order: order,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'qr_code_url': qrCodeUrl,
      'is_active': isActive,
      'order': order,
    };
  }

  @override
  List<Object?> get props =>
      [id, title, subtitle, startDate, endDate, qrCodeUrl, isActive, order];
}
