import 'package:flutter/material.dart';

import '../../../../core/styles/app_colors.dart';
import '../../../../data/models/mosque/mosque_bootstrap.dart';
import 'mosque_text_list_section.dart';

class ContentPanel extends StatelessWidget {
  final MosqueBootstrap mosque;
  final MosqueTextListKind kind;
  final IconData icon;
  final String title;
  final ColorScheme scheme;
  final VoidCallback? onAddPressed;

  const ContentPanel({
    super.key,
    required this.mosque,
    required this.kind,
    required this.icon,
    required this.title,
    required this.scheme,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final items = mosque.listByKind(kind);
    final fullTitle = '$title (${items.length})';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Row(
          children: [
            Expanded(
              child: Text(
                fullTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (onAddPressed != null)
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                color: AppColors.primary,
                visualDensity: VisualDensity.compact,
                onPressed: onAddPressed,
              ),
          ],
        ),
        childrenPadding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 400,
            child: MosqueTextListSection(mosque: mosque, kind: kind),
          ),
        ],
      ),
    );
  }
}
