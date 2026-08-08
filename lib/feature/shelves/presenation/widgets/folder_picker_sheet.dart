import 'package:flutter/material.dart';
import 'package:mindly/core/database/app_database.dart';
import '../../data/folders_repository.dart';

class FolderPickerSheet extends StatefulWidget {
  final int linkId;
  const FolderPickerSheet({super.key, required this.linkId});

  @override
  State<FolderPickerSheet> createState() => _FolderPickerSheetState();
}

class _FolderPickerSheetState extends State<FolderPickerSheet> {
  final _repo = FoldersRepository.instance;
  Set<int> _selectedFolderIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedFolders();
  }

  Future<void> _loadSelectedFolders() async {
    final folders = await _repo.getFoldersForLink(widget.linkId);
    setState(() {
      _selectedFolderIds = folders.map((f) => f.id).toSet();
      _loading = false;
    });
  }

  Future<void> _toggleFolder(int folderId) async {
    final isSelected = _selectedFolderIds.contains(folderId);

    setState(() {
      if (isSelected) {
        _selectedFolderIds.remove(folderId);
      } else {
        _selectedFolderIds.add(folderId);
      }
    });

    if (isSelected) {
      await _repo.removeLinkFromFolder(widget.linkId, folderId);
    } else {
      await _repo.addLinkToFolder(widget.linkId, folderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<Folder>>(
        stream: _repo.watchAllFolders(),
        builder: (context, snapshot) {
          if (_loading || !snapshot.hasData) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final folders = snapshot.data!;

          if (folders.isEmpty) {
            return const SizedBox(
              height: 150,
              child: Center(child: Text('No folders yet')),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              final isSelected = _selectedFolderIds.contains(folder.id);

              return ListTile(
                leading: const Icon(Icons.folder_rounded),
                title: Text(folder.name),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.circle_outlined),
                onTap: () => _toggleFolder(folder.id),
              );
            },
          );
        },
      ),
    );
  }
}