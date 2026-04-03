import 'package:flutter/material.dart';
import '../../../../data/models/app/app_settings_model.dart';
import '../../../../data/repositories/app_settings_repository.dart';
import '../widgets/about/about_widgets.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppSettingsModel?>(
      stream: AppSettingsRepository.streamAppSettings,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final settings = snapshot.data;
        if (settings == null || settings.aboutCategories.isEmpty) {
          return const AboutEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: settings.aboutCategories.length,
          itemBuilder: (context, index) {
            final category = settings.aboutCategories[index];
            return AboutCategoryView(category: category);
          },
        );
      },
    );
  }
}

