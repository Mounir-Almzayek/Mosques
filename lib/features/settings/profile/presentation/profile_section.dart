import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../core/refresh/settings_refresh_scope.dart';
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
  SettingsRefreshRegistry? _refreshRegistry;

  @override
  void dispose() {
    _refreshRegistry?.unregister('profile');
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
          _registerProfileRefresh(context, context.read<ProfileBloc>());
          final user = sl<IAuthRepository>().currentUser;

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

  void _registerProfileRefresh(BuildContext context, ProfileBloc bloc) {
    final registry = SettingsRefreshScope.of(context);
    if (_refreshRegistry != registry) {
      _refreshRegistry?.unregister('profile');
      _refreshRegistry = registry;
    }
    registry.register(
      SettingsRefreshDelegate(
        id: 'profile',
        label: S.of(context).tab_profile,
        hasUnsavedChanges: () => _profileHasUnsavedChanges(bloc),
        save: () => _saveProfileChanges(bloc),
        discard: () {
          _passwordController.clear();
          _phoneController.text = bloc.state.phone;
          setState(() => _terminateOther = true);
        },
      ),
    );
  }

  bool _profileHasUnsavedChanges(ProfileBloc bloc) {
    final passwordChanged = _passwordController.text.trim().isNotEmpty;
    final phoneChanged =
        _phoneController.text.trim() != bloc.state.phone.trim();
    return passwordChanged || phoneChanged;
  }

  Future<void> _saveProfileChanges(ProfileBloc bloc) async {
    final fallbackError = S.of(context).error_occurred;
    if (_passwordController.text.trim().isNotEmpty) {
      bloc.add(UpdatePasswordRequested(newPassword: _passwordController.text));
      final passwordState = await bloc.stream
          .firstWhere((state) => state.status != ProfileStatus.loading)
          .timeout(const Duration(seconds: 20));
      if (passwordState.status == ProfileStatus.failure) {
        throw Exception(passwordState.error ?? fallbackError);
      }
      _passwordController.clear();
    }

    if (_phoneController.text.trim() != bloc.state.phone.trim()) {
      bloc.add(UpdatePhoneRequested(_phoneController.text));
      final phoneState = await bloc.stream
          .firstWhere((state) => state.status != ProfileStatus.loading)
          .timeout(const Duration(seconds: 20));
      if (phoneState.status == ProfileStatus.failure) {
        throw Exception(phoneState.error ?? fallbackError);
      }
    }
  }

  String _localizedProfileError(S s, String? error) {
    return switch (error) {
      ProfileBloc.passwordTooShortError => s.profile_error_password_short,
      ProfileBloc.phoneEmptyError => s.profile_error_phone_empty,
      _ => error ?? s.error_occurred,
    };
  }
}
