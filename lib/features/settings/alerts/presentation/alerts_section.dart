import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../bloc/alerts_bloc.dart';
import '../widgets/alerts_section_body.dart';

/// Manages high-priority instant alerts with a saved-list + publish-on-demand flow.
///
/// Alerts are stored in [mosque.savedAlerts]. Each can be individually
/// published to the display for a configurable duration, then unpublished.
class AlertsSection extends StatelessWidget {
  const AlertsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AlertsBloc>(
      create: (_) =>
          AlertsBloc(mosqueRepository: sl<IMosqueRepository>())
            ..add(const LoadAlerts()),
      child: const AlertsSectionBody(),
    );
  }
}
