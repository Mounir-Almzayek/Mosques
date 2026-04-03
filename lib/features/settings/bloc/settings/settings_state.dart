import 'package:equatable/equatable.dart';
import '../../models/settings_edit_request.dart';

/// Single concrete state for settings to simplify handler logic and copyWith usage.
class SettingsState extends Equatable {
  final SettingsEditRequest request;
  final bool isLoading;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final String? error;

  const SettingsState({
    this.request = const SettingsEditRequest(mosque: null),
    this.isLoading = false,
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.error,
  });

  SettingsState copyWith({
    SettingsEditRequest? request,
    bool? isLoading,
    bool? isSaving,
    bool? hasUnsavedChanges,
    String? error,
  }) {
    return SettingsState(
      request: request ?? this.request,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    request,
    isLoading,
    isSaving,
    hasUnsavedChanges,
    error,
  ];
}
