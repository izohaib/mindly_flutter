import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mindly/core/router/route_constants.dart';
import '../../../core/theme/colors.dart';
import 'bloc/folders_cubit.dart';
import 'bloc/folders_state.dart';

class ShelvesScreen extends StatelessWidget {
  const ShelvesScreen({super.key});

  void _showCreateFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    final cubit = context.read<FoldersCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) =>
          AlertDialog(
            title: const Text('New Folder'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Folder name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  cubit.createFolder(controller.text);
                  Navigator.pop(dialogContext);
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shelves',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        centerTitle: true,
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _showCreateFolderDialog(context),
      //   child: const Icon(Icons.add),
      // ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => _showCreateFolderDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: BlocBuilder<FoldersCubit, FoldersState>(
          builder: (context, state) {
            if (state is FoldersLoading || state is FoldersInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FoldersError) {
              return Center(child: Text(state.message));
            }

            final folders = (state as FoldersSuccess).folders;

            if (folders.isEmpty) {
              return const Center(child: Text('No folders yet'));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final data = folders[index];
                final folder = data.folder;
                final images = data.recentImages;

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    context.push(
                      RouteConstants.folderDetail,
                      extra: {'folderId': folder.id, 'folderName': folder.name},
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _FolderThumbnail(images: images),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          folder.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${data.linkCount} ${data.linkCount == 1
                              ? 'link'
                              : 'links'}',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FolderThumbnail extends StatelessWidget {
  final List<String> images;

  const _FolderThumbnail({required this.images});

  Widget _cell(BuildContext context, int i) {
    if (i < images.length) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox.expand(
          child: Image.network(images[i], fit: BoxFit.cover),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: Theme
            .of(context)
            .colorScheme
            .surfaceContainerHighest,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        color: Theme
            .of(context)
            .colorScheme
            .surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.folder_rounded,
            size: 36,
            color: Theme
                .of(context)
                .colorScheme
                .onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _cell(context, 0)),
              const SizedBox(width: 4),
              Expanded(child: _cell(context, 1)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _cell(context, 2)),
              const SizedBox(width: 4),
              Expanded(child: _cell(context, 3)),
            ],
          ),
        ),
      ],
    );
  }
}