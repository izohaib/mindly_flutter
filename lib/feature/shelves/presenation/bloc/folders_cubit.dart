import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/folders_repository.dart';
import 'folders_state.dart';

class FoldersCubit extends Cubit<FoldersState> {
  final FoldersRepository foldersRepository;
  StreamSubscription? _foldersSubscription;
  StreamSubscription? _folderLinksSubscription;

  FoldersCubit(this.foldersRepository) : super(const FoldersInitial()) {
    _listenToFolders();
  }

  void _listenToFolders() {
    emit(const FoldersLoading());
    _foldersSubscription = foldersRepository.watchAllFolders().listen(
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

  /// Call when opening a folder's detail screen
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

  /// Call when leaving the folder detail screen
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

  @override
  Future<void> close() {
    _foldersSubscription?.cancel();
    _folderLinksSubscription?.cancel();
    return super.close();
  }
}