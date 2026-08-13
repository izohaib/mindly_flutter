import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/folders_repository.dart';
import 'folders_state.dart';

class FoldersCubit extends Cubit<FoldersState> {
  final FoldersRepository foldersRepository;
  StreamSubscription? _foldersSubscription;
  StreamSubscription? _folderLinksSubscription;

  FoldersCubit(this.foldersRepository) : super(const FoldersInitial()) {
    _listenToFoldersWithData();
  }

  void _listenToFoldersWithData() {
    emit(const FoldersLoading());
    _foldersSubscription = foldersRepository.watchAllFoldersWithDetails().listen(
          (folders) {
        if (state is FoldersSuccess) {
          emit((state as FoldersSuccess).copyWith(folders: folders));
        } else {
          emit(FoldersSuccess(folders: folders));
        }
      },
      onError: (e) => emit(FoldersError(message: e.toString())),
    );
  }

  Future<void> createFolder(String name) async {
    if (name.trim().isEmpty) return;
    await foldersRepository.createFolder(name.trim());
  }

  Future<void> deleteFolder(int folderId) async {
    await foldersRepository.deleteFolder(folderId);
  }

  void openFolder(int folderId) {
    if (state is! FoldersSuccess) return;
    final currentState = state as FoldersSuccess;

    emit(currentState.copyWith(selectedFolderId: folderId, linksInSelectedFolder: []));

    _folderLinksSubscription?.cancel();
    _folderLinksSubscription =
        foldersRepository.watchLinksInFolder(folderId).listen((links) {
          if (state is FoldersSuccess) {
            emit((state as FoldersSuccess).copyWith(linksInSelectedFolder: links));
          }
        });
  }

  void closeFolder() {
    _folderLinksSubscription?.cancel();
    _folderLinksSubscription = null;
    if (state is FoldersSuccess) {
      emit((state as FoldersSuccess).copyWith(selectedFolderId: null, linksInSelectedFolder: []));
    }
  }

  Future<void> addLinkToFolder(int linkId, int folderId) async {
    await foldersRepository.addLinkToFolder(linkId, folderId);
  }

  Future<void> removeLinkFromFolder(int linkId, int folderId) async {
    await foldersRepository.removeLinkFromFolder(linkId, folderId);
  }

  /// Call when opening a link's detail screen, loads which folders it already belongs to
  Future<void> loadFoldersForLink(int linkId) async {
    if (state is! FoldersSuccess) return;
    final currentState = state as FoldersSuccess;

    final linkFolders = await foldersRepository.getFoldersForLink(linkId);

    emit(currentState.copyWith(linkFolderIds: linkFolders.map((f) => f.id).toSet()));
  }

  /// Toggle a folder on/off for a given link, used by the folder popover on detail screen
  Future<void> toggleLinkFolder(int linkId, int folderId) async {
    if (state is! FoldersSuccess) return;
    final currentState = state as FoldersSuccess;

    final isSelected = currentState.linkFolderIds.contains(folderId);
    final updatedIds = Set<int>.from(currentState.linkFolderIds);
    isSelected ? updatedIds.remove(folderId) : updatedIds.add(folderId);

    emit(currentState.copyWith(linkFolderIds: updatedIds));

    isSelected
        ? await removeLinkFromFolder(linkId, folderId)
        : await addLinkToFolder(linkId, folderId);
  }

  @override
  Future<void> close() {
    _foldersSubscription?.cancel();
    _folderLinksSubscription?.cancel();
    return super.close();
  }
}