import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mindly/core/database/app_database.dart';
import 'package:mindly/feature/feed/data/link_repository.dart';
import '../shelves/presenation/widgets/folder_picker_sheet.dart';

class LinkDetailScreen extends StatelessWidget {
  final Link link;
  const LinkDetailScreen({super.key, required this.link});

  Future<void> _deleteLink(BuildContext context) async {
    await LinkRepository.instance.deleteLink(link.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link deleted')),
    );
    context.pop();
  }

  // void _shareLink() {
  //   Share.share(link.url);
  // }

  void _openFolderPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FolderPickerSheet(linkId: link.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (link.imageUrl != null && link.imageUrl!.isNotEmpty)
            Image.network(
              link.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 250,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              link.title ?? link.url,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => _deleteLink(context),
                  icon: const Icon(Icons.delete_outline),
                ),
                IconButton(
                  onPressed: (){
                    // _sharelink();
                  },
                  icon: const Icon(Icons.share_outlined),
                ),
                IconButton(
                  onPressed: () => _openFolderPicker(context),
                  icon: const Icon(Icons.folder_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}