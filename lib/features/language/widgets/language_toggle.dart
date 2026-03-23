import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/language/language_bloc.dart';
import '../../../core/enums/app_language.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        final isArabic = state.language == AppLanguage.arabic;
        
        return TextButton(
          onPressed: () {
            context.read<LanguageBloc>().add(
              ChangeLanguage(isArabic ? AppLanguage.english : AppLanguage.arabic),
            );
          },
          child: Text(
            isArabic ? AppLanguage.english.name : AppLanguage.arabic.name,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}

