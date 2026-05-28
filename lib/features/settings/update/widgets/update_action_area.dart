import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/update/update_status.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../bloc/update_bloc.dart';

class UpdateActionArea extends StatelessWidget {
  final String downloadLink;
  final ThemeData theme;
  final S s;
  final Color primary;

  const UpdateActionArea({
    super.key,
    required this.downloadLink,
    required this.theme,
    required this.s,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdateBloc, UpdateState>(
      listener: (context, state) {
        if (state.status == UpdateStatus.failure) {
          UnifiedSnackbar.error(
            context,
            message: state.error ?? s.update_failure,
          );
        }
      },
      builder: (context, state) {
        if (downloadLink.isEmpty) {
          return Text(
            s.update_no_link,
            style: TextStyle(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          );
        }

        if (state.status == UpdateStatus.downloading) {
          return Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: state.progress,
                  color: primary,
                  backgroundColor: primary.withValues(alpha: 0.15),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                s.update_downloading((state.progress * 100).toStringAsFixed(1)),
                style: theme.textTheme.bodySmall,
              ),
            ],
          );
        }

        if (state.status == UpdateStatus.success) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, color: primary),
              const SizedBox(width: 8),
              Text(
                s.update_success,
                style: TextStyle(color: primary, fontWeight: FontWeight.bold),
              ),
            ],
          );
        }

        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<UpdateBloc>().add(
                DownloadUpdateRequested(downloadLink),
              );
            },
            icon: const Icon(Icons.download_rounded),
            label: Text(
              s.update_download,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
