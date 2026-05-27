import 'package:flutter/material.dart';
import '../../../../../core/l10n/generated/l10n.dart';

class AlbumUrlList extends StatelessWidget {
  final List<String> urls;
  final ValueChanged<String> onUrlAdded;
  final void Function(int) onUrlRemoved;

  const AlbumUrlList({
    super.key,
    required this.urls,
    required this.onUrlAdded,
    required this.onUrlRemoved,
  });

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).photo_studio_add_url),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'https://example.com/image.jpg',
            labelText: S.of(context).url_label,
          ),
          keyboardType: TextInputType.url,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) onUrlAdded(url);
              Navigator.pop(ctx);
            },
            child: Text(S.of(context).add_label),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...urls.asMap().entries.map((entry) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              entry.value,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, size: 40),
            ),
          ),
          title: Text(entry.value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => onUrlRemoved(entry.key),
          ),
        )),
        TextButton.icon(
          onPressed: () => _showAddDialog(context),
          icon: const Icon(Icons.add),
          label: Text(S.of(context).add_label),
        ),
      ],
    );
  }
}
