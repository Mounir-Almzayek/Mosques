import 'package:equatable/equatable.dart';

import '../about/about_category_model.dart';

export '../about/about_category_model.dart';
export '../about/about_section_model.dart';

/// Assembled cross-platform update metadata — 1:1 with backend
/// `AppUpdateResponse`.
class AppUpdate extends Equatable {
  final String latestVersion;
  final String androidLink;
  final String windowsLink;
  final String iosLink;
  final String macosLink;
  final String linuxLink;
  final String releaseNotes;
  final bool isUpdateAvailable;

  const AppUpdate({
    this.latestVersion = '1.0.0',
    this.androidLink = '',
    this.windowsLink = '',
    this.iosLink = '',
    this.macosLink = '',
    this.linuxLink = '',
    this.releaseNotes = '',
    this.isUpdateAvailable = false,
  });

  factory AppUpdate.fromJson(Map<String, dynamic> json) {
    return AppUpdate(
      latestVersion: json['latestVersion']?.toString() ?? '1.0.0',
      androidLink: json['androidLink']?.toString() ?? '',
      windowsLink: json['windowsLink']?.toString() ?? '',
      iosLink: json['iosLink']?.toString() ?? '',
      macosLink: json['macosLink']?.toString() ?? '',
      linuxLink: json['linuxLink']?.toString() ?? '',
      releaseNotes: json['releaseNotes']?.toString() ?? '',
      isUpdateAvailable: json['isUpdateAvailable'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'latestVersion': latestVersion,
    'androidLink': androidLink,
    'windowsLink': windowsLink,
    'iosLink': iosLink,
    'macosLink': macosLink,
    'linuxLink': linuxLink,
    'releaseNotes': releaseNotes,
    'isUpdateAvailable': isUpdateAvailable,
  };

  @override
  List<Object?> get props => [
    latestVersion,
    androidLink,
    windowsLink,
    iosLink,
    macosLink,
    linuxLink,
    releaseNotes,
    isUpdateAvailable,
  ];
}

class LatestRelease extends Equatable {
  final String platform;
  final String version;
  final String downloadUrl;
  final String releaseNotes;
  final bool isUpdateAvailable;

  const LatestRelease({
    this.platform = '',
    this.version = '',
    this.downloadUrl = '',
    this.releaseNotes = '',
    this.isUpdateAvailable = false,
  });

  factory LatestRelease.fromJson(Map<String, dynamic> json) {
    return LatestRelease(
      platform: json['platform']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      downloadUrl: json['downloadUrl']?.toString() ?? '',
      releaseNotes: json['releaseNotes']?.toString() ?? '',
      isUpdateAvailable: json['isUpdateAvailable'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'version': version,
    'downloadUrl': downloadUrl,
    'releaseNotes': releaseNotes,
    'isUpdateAvailable': isUpdateAvailable,
  };

  @override
  List<Object?> get props => [
    platform,
    version,
    downloadUrl,
    releaseNotes,
    isUpdateAvailable,
  ];
}

/// Public app launch config — 1:1 with backend `AppBootstrapResponse`
/// (`GET /mobile/app/bootstrap`). Replaces the Firebase-era `AppSettingsModel`.
class AppConfig extends Equatable {
  final String supportPhone;
  final List<String> backgroundLibraryUrls;
  final String backgroundFolderUrl;
  final List<AboutCategoryModel> aboutCategories;
  final AppUpdate update;
  final LatestRelease? latestRelease;

  const AppConfig({
    this.supportPhone = '',
    this.backgroundLibraryUrls = const [],
    this.backgroundFolderUrl = '',
    this.aboutCategories = const [],
    this.update = const AppUpdate(),
    this.latestRelease,
  });

  // Backward-compatible getters preserved from AppSettingsModel.
  String get latestVersion => update.latestVersion;
  String get updateMessage => update.releaseNotes;

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> asMap(Object? value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return const {};
    }

    final latestRelease = asMap(json['latestRelease']);

    return AppConfig(
      supportPhone: json['supportPhone']?.toString() ?? '',
      backgroundLibraryUrls:
          (json['backgroundLibraryUrls'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      backgroundFolderUrl: json['backgroundFolderUrl']?.toString() ?? '',
      aboutCategories:
          (json['aboutCategories'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => AboutCategoryModel.fromMap(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          const [],
      update: AppUpdate.fromJson(asMap(json['update'])),
      latestRelease: latestRelease.isEmpty
          ? null
          : LatestRelease.fromJson(latestRelease),
    );
  }

  Map<String, dynamic> toJson() => {
    'supportPhone': supportPhone,
    'backgroundLibraryUrls': backgroundLibraryUrls,
    'backgroundFolderUrl': backgroundFolderUrl,
    'aboutCategories': aboutCategories.map((c) => c.toMap()).toList(),
    'update': update.toJson(),
    'latestRelease': latestRelease?.toJson(),
  };

  @override
  List<Object?> get props => [
    supportPhone,
    backgroundLibraryUrls,
    backgroundFolderUrl,
    aboutCategories,
    update,
    latestRelease,
  ];
}
