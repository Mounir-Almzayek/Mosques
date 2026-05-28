import 'package:flutter/material.dart';

import '../../../../core/widgets/buttons/app_button.dart';

class DesignSaveBar extends StatelessWidget {
  final bool isSaving;
  final String savingLabel;
  final String saveLabel;
  final VoidCallback onSave;

  const DesignSaveBar({
    super.key,
    required this.isSaving,
    required this.savingLabel,
    required this.saveLabel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: AppButton.elevated(
          label: isSaving ? savingLabel : saveLabel,
          onPressed: onSave,
          isLoading: isSaving,
          disabled: isSaving,
          leadingIcon: Icons.cloud_upload_rounded,
          height: 56,
          fontSize: 16,
          borderRadius: 16,
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
