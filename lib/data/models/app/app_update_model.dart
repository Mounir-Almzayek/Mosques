import 'package:equatable/equatable.dart';

class AppUpdateModel extends Equatable {
  final String latestVersion;
  final String androidLink;
  final String windowsLink;
  final String iosLink;
  final String macosLink;
  final String linuxLink;
  final String releaseNotes;

  const AppUpdateModel({
    this.latestVersion = '1.0.0',
    this.androidLink = '',
    this.windowsLink = '',
    this.iosLink = '',
    this.macosLink = '',
    this.linuxLink = '',
    this.releaseNotes = '',
  });

  factory AppUpdateModel.fromMap(Map<String, dynamic> map) {
    return AppUpdateModel(
      latestVersion: map['latest_version'] ?? '1.0.0',
      androidLink: map['android_link'] ?? '',
      windowsLink: map['windows_link'] ?? '',
      iosLink: map['ios_link'] ?? '',
      macosLink: map['macos_link'] ?? '',
      linuxLink: map['linux_link'] ?? '',
      releaseNotes: map['release_notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latest_version': latestVersion,
      'android_link': androidLink,
      'windows_link': windowsLink,
      'ios_link': iosLink,
      'macos_link': macosLink,
      'linux_link': linuxLink,
      'release_notes': releaseNotes,
    };
  }

  @override
  List<Object?> get props => [
        latestVersion,
        androidLink,
        windowsLink,
        iosLink,
        macosLink,
        linuxLink,
        releaseNotes,
      ];
}
