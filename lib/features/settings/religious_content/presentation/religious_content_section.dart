import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../bloc/religious_content_bloc.dart';
import '../widgets/religious_content_section_body.dart';

class ReligiousContentSection extends StatelessWidget {
  const ReligiousContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReligiousContentBloc>(
      create: (_) =>
          ReligiousContentBloc(mosqueRepository: sl<IMosqueRepository>())
            ..add(const LoadReligiousContent()),
      child: const ReligiousContentSectionBody(),
    );
  }
}
