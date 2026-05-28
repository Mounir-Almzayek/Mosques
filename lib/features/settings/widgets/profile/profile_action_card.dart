import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../bloc/profile/profile_bloc.dart';

class ProfileActionCard extends StatefulWidget {
  final ProfileState state;
  final TextEditingController passwordController;
  final bool terminateOther;
  final ValueChanged<bool> onTerminateChanged;

  const ProfileActionCard({
    super.key,
    required this.state,
    required this.passwordController,
    required this.terminateOther,
    required this.onTerminateChanged,
  });

  @override
  State<ProfileActionCard> createState() => _ProfileActionCardState();
}

class _ProfileActionCardState extends State<ProfileActionCard> {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isLoading = widget.state.status == ProfileStatus.loading;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.profile_new_password,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.passwordController,
              obscureText: true,
              enabled: !isLoading,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline, color: primary),
                hintText: s.password_hint,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                s.profile_terminate_other,
                style: theme.textTheme.bodyMedium,
              ),
              subtitle: Text(
                s.profile_terminate_hint,
                style: theme.textTheme.bodySmall,
              ),
              value: widget.terminateOther,
              onChanged: isLoading ? null : widget.onTerminateChanged,
              activeColor: primary,
            ),
            const SizedBox(height: 24),
            AppButton.elevated(
              label: s.profile_save_changes,
              isLoading: isLoading,
              disabled: isLoading,
              onPressed: () {
                context.read<ProfileBloc>().add(
                      UpdatePasswordRequested(
                        newPassword: widget.passwordController.text,
                      ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
