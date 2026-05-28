import 'package:equatable/equatable.dart';
import '../../../../core/enums/profile/profile_status.dart';

export '../../../../core/enums/profile/profile_status.dart';

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String? error;
  final String phone;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.error,
    this.phone = '',
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? error,
    String? phone,
  }) {
    return ProfileState(
      status: status ?? this.status,
      error: error,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [status, error, phone];
}
