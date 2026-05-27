import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/media/media_widgets.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../../bloc/settings/settings_bloc.dart';

class PhotoStudioSection extends StatelessWidget {
  final MosqueModel mosque;

  const PhotoStudioSection({super.key, required this.mosque});

  Future<void> _showAddUrlDialog(BuildContext context) async {
    final s = S.of(context);
    final bloc = context.read<SettingsBloc>();
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.photo_studio_add_url),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: 'https://example.com/image.jpg',
            labelText: s.url_label,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                bloc.add(PhotoStudioUrlAdded(url));
              }
              Navigator.pop(ctx);
            },
            child: Text(s.add_label),
          ),
        ],
      ),
    );

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final urls = mosque.albumImageUrls;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Main content
        if (urls.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 64,
                  color: AppColors.primarySurface,
                ),
                const SizedBox(height: 16),
                Text(s.photo_studio_empty),
              ],
            ),
          )
        else
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: urls.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final url = urls[index];
              return Card(
                child: ListTile(
                  leading: CachedImage.thumbnail(
                    url: url,
                    size: 56,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  title: Text(
                    url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    onPressed: () {
                      context.read<SettingsBloc>().add(
                        PhotoStudioUrlRemoved(url),
                      );
                    },
                  ),
                ),
              );
            },
          ),

        // Floating action button (bottom-right)
        Positioned(
          right: 16,
          bottom: 100,
          child: FloatingActionButton(
            heroTag: 'photo_studio_fab',
            onPressed: () => _showAddUrlDialog(context),
            child: const Icon(Icons.add),
          ),
        ),

        // Save button (bottom)
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              if (!state.hasUnsavedChanges) return const SizedBox.shrink();
              return FilledButton.icon(
                onPressed: state.isSaving
                    ? null
                    : () => context
                        .read<SettingsBloc>()
                        .add(const SavePhotoStudioRequested()),
                icon: state.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(S.of(context).save),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
