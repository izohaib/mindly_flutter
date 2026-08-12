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
      builder: (dialogContext) => AlertDialog(
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
                childAspectRatio: 1.1,
              ),
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),

                  onTap: () {
                    context.push(RouteConstants.folderDetail, extra: folder.id);
                  },

                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.folder_rounded, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          folder.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
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
