import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_widgets.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _terminateOther = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProfileBloc(authRepository: sl<IAuthRepository>())
            ..add(LoadProfileRequested()),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          final s = S.of(context);
          if (state.status == ProfileStatus.success) {
            UnifiedSnackbar.success(context, message: s.saved_successfully);
            _passwordController.clear();
          } else if (state.status == ProfileStatus.failure) {
            UnifiedSnackbar.error(
              context,
              message: _localizedProfileError(s, state.error),
            );
          }
        },
        builder: (context, state) {
          final user = FirebaseAuth.instance.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileInfoCard(user: user),
                const SizedBox(height: 24),
                ProfileActionCard(
                  state: state,
                  passwordController: _passwordController,
                  terminateOther: _terminateOther,
                  onTerminateChanged: (v) =>
                      setState(() => _terminateOther = v),
                ),
                const SizedBox(height: 24),
                ProfilePhoneCard(
                  state: state,
                  phoneController: _phoneController,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _localizedProfileError(S s, String? error) {
    return switch (error) {
      ProfileBloc.passwordTooShortError => s.profile_error_password_short,
      ProfileBloc.phoneEmptyError => s.profile_error_phone_empty,
      _ => error ?? s.error_occurred,
    };
  }
}
