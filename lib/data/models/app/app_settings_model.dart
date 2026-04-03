import 'package:equatable/equatable.dart';
import '../about/about_category_model.dart';
import 'app_update_model.dart';

class AppSettingsModel extends Equatable {
  final List<AboutCategoryModel> aboutCategories;
  final AppUpdateModel update;
  final String supportPhone;
  final bool allowRegistration;

  // Backward compatibility fields
  String get latestVersion => update.latestVersion;
  String get updateMessage => update.releaseNotes;

  const AppSettingsModel({
    this.aboutCategories = const [],
    this.update = const AppUpdateModel(),
    this.supportPhone = '',
    this.allowRegistration = true,
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
    };
  }

  @override
  List<Object?> get props => [aboutCategories, update, supportPhone, allowRegistration];
}
