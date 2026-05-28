import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../bloc/general_bloc.dart';
import '../widgets/general_section_body.dart';

class GeneralSection extends StatelessWidget {
  const GeneralSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GeneralBloc>(
      create: (_) =>
          GeneralBloc(mosqueRepository: sl<IMosqueRepository>())
            ..add(const LoadGeneral()),
      child: const GeneralSectionBody(),
    );
  }
}
