import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/registration_type.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../data/models/app/app_settings_model.dart';
import '../../../data/repositories/app_settings_repository.dart';
import '../bloc/registration/registration_bloc.dart';
import '../bloc/registration/registration_event.dart';
import 'registration_state.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mosqueIdController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _mosqueIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<RegistrationBloc>().add(
        RegistrationSubmitted(
          email: _emailController.text,
          password: _passwordController.text,
          phone: _phoneController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return FutureBuilder<AppSettingsModel?>(
      future: AppSettingsRepository.getAppSettings(),
      builder: (context, snapshot) {
        final canOpenRegistration = snapshot.data?.allowRegistration ?? true;

        return BlocListener<RegistrationBloc, RegistrationState>(
          listener: (context, state) {
            if (state.status == RegistrationStatus.success) {
              _showSuccess(state.type);
            } else if (state.status == RegistrationStatus.failure) {
              UnifiedSnackbar.error(
                context,
                message: state.error ?? s.error_occurred,
              );
            }
          },
          child: Scaffold(
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: canOpenRegistration
                          ? Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildHeader(theme, s),
                                  const SizedBox(height: 32),
                                  _buildTypeChooser(s),
                                  const SizedBox(height: 24),
                                  _buildFields(s),
                                  const SizedBox(height: 32),
                                  _buildAction(s),
                                  const SizedBox(height: 16),
                                  _buildLoginLink(theme, s),
                                ],
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHeader(theme, s),
                                const SizedBox(height: 24),
                                const Text(
                                  'Registration is currently disabled.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  snapshot.data?.supportPhone.isNotEmpty == true
                                      ? s.contact_dev_message(
                                          snapshot.data!.supportPhone,
                                        )
                                      : 'Please contact the administrator for access.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                _buildLoginLink(theme, s),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, S s) {
    return Column(
      children: [
        const Icon(Icons.mosque_outlined, size: 64, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          s.register_title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s.register_subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChooser(S s) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        return SegmentedButton<RegistrationType>(
          segments: [
            ButtonSegment(
              value: RegistrationType.newMosque,
              label: Text(s.register_type_new),
              icon: const Icon(Icons.add_business),
            ),
            ButtonSegment(
              value: RegistrationType.existingMosque,
              label: Text(s.register_type_existing),
              icon: const Icon(Icons.link),
            ),
          ],
          selected: {state.type},
          onSelectionChanged: (set) => context.read<RegistrationBloc>().add(
            RegistrationTypeChanged(set.first),
          ),
        );
      },
    );
  }

  Widget _buildFields(S s) {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: s.email_label,
            hintText: s.email_hint,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          validator: (v) =>
              (v == null || v.isEmpty) ? s.validation_email_required : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: s.password_label,
            prefixIcon: const Icon(Icons.lock_outline),
          ),
          validator: (v) =>
              (v == null || v.length < 6) ? s.validation_password_short : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: s.registration_phone,
            prefixIcon: const Icon(Icons.phone),
          ),
          validator: (v) => (v == null || v.isEmpty)
              ? s.validation_email_required
              : null, // Uses generic required text or define specific one
        ),
        const SizedBox(height: 16),
        BlocBuilder<RegistrationBloc, RegistrationState>(
          builder: (context, state) {
            if (state.type.isExisting) {
              return _buildExistingMosqueMessage(s);
            }
            return _buildMosqueIdField(s, state);
          },
        ),
      ],
    );
  }

  Widget _buildExistingMosqueMessage(S s) {
    return FutureBuilder<AppSettingsModel?>(
      future: AppSettingsRepository.getAppSettings(),
      builder: (context, snapshot) {
        final phone = snapshot.data?.supportPhone ?? '...';
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  s.contact_dev_message(phone),
                  style: const TextStyle(fontSize: 13, color: Colors.blue),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMosqueIdField(S s, RegistrationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _mosqueIdController,
          onChanged: (v) => context.read<RegistrationBloc>().add(
            RegistrationMosqueIdChanged(v),
          ),
          decoration: InputDecoration(
            labelText: s.mosque_id_label,
            hintText: s.mosque_id_hint,
            prefixIcon: const Icon(Icons.tag),
            errorText: state.isIdAvailable ? null : s.mosque_id_taken,
          ),
          validator: (v) =>
              (v == null || v.isEmpty) ? s.validation_mosque_id_required : null,
        ),
        if (!state.isIdAvailable && state.suggestedId != null) ...[
          const SizedBox(height: 4),
          InkWell(
            onTap: () {
              _mosqueIdController.text = state.suggestedId!;
              context.read<RegistrationBloc>().add(
                RegistrationMosqueIdChanged(state.suggestedId!),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                s.mosque_id_suggestion(state.suggestedId!),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAction(S s) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        if (state.status == RegistrationStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _submit,
          child: Text(
            s.register_button,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink(ThemeData theme, S s) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(s.login_link, style: TextStyle(color: theme.primaryColor)),
    );
  }

  void _showSuccess(RegistrationType type) {
    final s = S.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 48,
        ),
        content: Text(
          type.isNew
              ? s.registration_success_new
              : s.registration_success_existing,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // dialog
              Navigator.of(context).pop(); // back to login
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

