import 'package:flutter/material.dart';
import '../../../../../core/l10n/generated/l10n.dart';
import '../../../bloc/profile/profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePhoneCard extends StatefulWidget {
  final ProfileState state;
  final TextEditingController phoneController;

  const ProfilePhoneCard({
    super.key,
    required this.state,
    required this.phoneController,
  });

  @override
  State<ProfilePhoneCard> createState() => _ProfilePhoneCardState();
}

class _ProfilePhoneCardState extends State<ProfilePhoneCard> {
  @override
  void didUpdateWidget(covariant ProfilePhoneCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.phone != oldWidget.state.phone &&
        widget.phoneController.text.isEmpty) {
      widget.phoneController.text = widget.state.phone;
    }
  }

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
              s.profile_phone_label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.profile_phone_hint,
                      style: theme.textTheme.bodySmall?.copyWith(color: primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.phoneController,
              keyboardType: TextInputType.phone,
              enabled: !isLoading,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone, color: primary),
                hintText: s.registration_phone,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<ProfileBloc>().add(
                              UpdatePhoneRequested(widget.phoneController.text),
                            );
                      },
                child: isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        s.profile_save_changes,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
