import 'package:equatable/equatable.dart';

import '../../../data/models/mosque_model.dart';

/// Draft mosque data for the settings screen (mirrors [LoginRequest] pattern).
class SettingsEditRequest extends Equatable {
  final MosqueModel? mosque;

  const SettingsEditRequest({this.mosque});

  SettingsEditRequest copyWith({MosqueModel? mosque}) {
    return SettingsEditRequest(mosque: mosque ?? this.mosque);
  }

  @override
  List<Object?> get props => [mosque];
}
