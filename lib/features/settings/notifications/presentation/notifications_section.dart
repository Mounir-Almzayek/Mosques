import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../data/repositories/interfaces/notifications_repository_interface.dart';
import '../bloc/notifications_bloc.dart';
import '../widgets/notifications_section_body.dart';

class NotificationsSection extends StatelessWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<NotificationsBloc>();
      return const NotificationsSectionBody();
    } catch (_) {
      // Standalone fallback for tests or future routes.
    }
    return BlocProvider(
      create: (_) =>
          NotificationsBloc(repository: sl<INotificationsRepository>())
            ..add(const LoadNotifications()),
      child: const NotificationsSectionBody(),
    );
  }
}
