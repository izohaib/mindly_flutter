import 'package:mindly/core/database/app_database.dart';

class FolderCardData {
  final Folder folder;
  final int linkCount;
  final List<String> recentImages;

  const FolderCardData({
    required this.folder,
    required this.linkCount,
    required this.recentImages,
  });
}