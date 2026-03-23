import 'package:equatable/equatable.dart';

import '../models/settings_edit_request.dart';

abstract class SettingsState extends Equatable {
  final SettingsEditRequest request;

  const SettingsState({required this.request});

  @override
  List<Object?> get props => [request];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial({required super.request});

  SettingsInitial copyWith({SettingsEditRequest? request}) {
    return SettingsInitial(request: request ?? this.request);
  }
}

class SettingsLoading extends SettingsState {
  const SettingsLoading({required super.request});

  SettingsLoading copyWith({SettingsEditRequest? request}) {
    return SettingsLoading(request: request ?? this.request);
  }
}

class SettingsLoaded extends SettingsState {
  const SettingsLoaded({required super.request});

  SettingsLoaded copyWith({SettingsEditRequest? request}) {
    return SettingsLoaded(request: request ?? this.request);
  }
}

class SettingsSaving extends SettingsState {
  const SettingsSaving({required super.request});

  SettingsSaving copyWith({SettingsEditRequest? request}) {
    return SettingsSaving(request: request ?? this.request);
  }
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({
    required super.request,
    required this.message,
  });

  @override
  List<Object?> get props => [request, message];

  SettingsError copyWith({
    SettingsEditRequest? request,
    String? message,
  }) {
    return SettingsError(
      request: request ?? this.request,
      message: message ?? this.message,
    );
  }
}
