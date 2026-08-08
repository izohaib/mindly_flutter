import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../feed/presentation/widgets/link_card.dart';
import 'bloc/folders_cubit.dart';
import 'bloc/folders_state.dart';


class FolderDetailScreen extends StatefulWidget {
  final int folderId;
  const FolderDetailScreen({super.key, required this.folderId});

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FoldersCubit>().openFolder(widget.folderId);
  }

  @override
  void dispose() {
    context.read<FoldersCubit>().closeFolder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Folder')),
      body: BlocBuilder<FoldersCubit, FoldersState>(
        builder: (context, state) {
          if (state is! FoldersSuccess) {
            return const Center(child: CircularProgressIndicator());
          }

          final links = state.linksInSelectedFolder;

          if (links.isEmpty) {
            return const Center(child: Text('No links in this folder'));
          }

          return MasonryGridView.count(
            padding: const EdgeInsets.all(12),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: links.length,
            itemBuilder: (context, index) => LinkFeed(link: links[index]),
          );
        },
      ),
    );
  }
}