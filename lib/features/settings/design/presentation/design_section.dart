import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../bloc/design_bloc.dart';
import '../widgets/design_section_body.dart';

class DesignSection extends StatelessWidget {
  const DesignSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DesignBloc>(
      create: (_) =>
          DesignBloc(mosqueRepository: sl<IMosqueRepository>())
            ..add(const LoadDesign()),
      child: const DesignSectionBody(),
    );
  }
}
