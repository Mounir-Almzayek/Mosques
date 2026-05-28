import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../design/bloc/design_bloc.dart';
import '../../general/bloc/general_bloc.dart';
import '../bloc/iqama_bloc.dart';
import '../widgets/prayer_iqama_section_body.dart';

class PrayerIqamaSection extends StatelessWidget {
  const PrayerIqamaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GeneralBloc>(
          create: (_) =>
              GeneralBloc(mosqueRepository: sl<IMosqueRepository>())
                ..add(const LoadGeneral()),
        ),
        BlocProvider<IqamaBloc>(
          create: (_) =>
              IqamaBloc(mosqueRepository: sl<IMosqueRepository>())
                ..add(const LoadIqama()),
        ),
        BlocProvider<DesignBloc>(
          create: (_) =>
              DesignBloc(mosqueRepository: sl<IMosqueRepository>())
                ..add(const LoadDesign()),
        ),
      ],
      child: const PrayerIqamaSectionBody(),
    );
  }
}
