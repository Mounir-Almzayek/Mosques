import 'package:flutter/material.dart';
import '../../../../../data/models/about_section_model.dart';
import '../../../../../core/l10n/generated/l10n.dart';
import 'about_item_view.dart';

class AboutCategoryView extends StatelessWidget {
  final AboutCategoryModel category;

  const AboutCategoryView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Text(
            category.title.isNotEmpty ? category.title : S.of(context).about_category_default,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: category.sections.map((s) => AboutItemView(section: s)).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
