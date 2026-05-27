import 'package:equatable/equatable.dart';
import '../about/about_category_model.dart';
import 'app_update_model.dart';

class AppSettingsModel extends Equatable {
  final List<AboutCategoryModel> aboutCategories;
  final AppUpdateModel update;
  final String supportPhone;
  final bool allowRegistration;

  /// Global background folder URL (set in Firebase app_settings/global).
  final String? backgroundFolderUrl;

  /// List of available background image URLs (set in Firebase app_settings/global).
  /// These replace the old hardcoded asset presets and serve as the selectable
  /// background library in the design settings.
  final List<String> backgroundLibraryUrls;

  // Backward compatibility fields
  String get latestVersion => update.latestVersion;
  String get updateMessage => update.releaseNotes;

  const AppSettingsModel({
    this.aboutCategories = const [],
    this.update = const AppUpdateModel(),
    this.supportPhone = '',
    this.allowRegistration = true,
    this.backgroundFolderUrl,
    this.backgroundLibraryUrls = const [],
  });

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      supportPhone: map['support_phone'] ?? '',
      allowRegistration: map['allow_registration'] ?? true,
      aboutCategories:
          (map['about_categories'] as List<dynamic>?)
              ?.map(
                (e) => AboutCategoryModel.fromMap(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      backgroundFolderUrl: map['background_folder_url'] as String?,
      backgroundLibraryUrls: (map['background_library_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      update: AppUpdateModel.fromMap(
        map['update'] ??
            {
              'latest_version': map['latest_version'],
              'release_notes': map['update_message'],
            },
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'support_phone': supportPhone,
      'allow_registration': allowRegistration,
      'about_categories': aboutCategories.map((e) => e.toMap()).toList(),
      'update': update.toMap(),
      if (backgroundFolderUrl != null) 'background_folder_url': backgroundFolderUrl,
      if (backgroundLibraryUrls.isNotEmpty) 'background_library_urls': backgroundLibraryUrls,
    };
  }

  @override
  List<Object?> get props => [aboutCategories, update, supportPhone, allowRegistration, backgroundFolderUrl, backgroundLibraryUrls];
}
