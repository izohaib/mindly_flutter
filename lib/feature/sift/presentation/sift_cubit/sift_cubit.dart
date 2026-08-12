import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindly/feature/feed/data/link_repository.dart';
import 'sift_state.dart';

class SiftCubit extends Cubit<SiftState> {
  final LinkRepository _repository;

  SiftCubit({LinkRepository? repository})
      : _repository = repository ?? LinkRepository.instance,
        super(SiftLoading());

  Future<void> loadLinks() async {
    emit(SiftLoading());
    try {
      final links = await _repository.getAllLinks();
      emit(links.isEmpty
          ? SiftEmpty()
          : SiftLoaded(links: links, currentIndex: 0));
    } catch (e) {
      emit(SiftError('Failed to load links'));
    }
  }

  /// Swipe left = delete
  Future<void> deleteCurrent() async {
    final current = state;
    if (current is! SiftLoaded || current.currentLink == null) return;

    final link = current.currentLink!;
    emit(current.copyWith(currentIndex: current.currentIndex + 1));

    try {
      await _repository.deleteLink(link.id);
    } catch (e) {
      emit(current); // rollback on failure
    }
  }

  /// Swipe right = keep (no DB write)
  void keepCurrent() {
    final current = state;
    if (current is! SiftLoaded) return;
    emit(current.copyWith(currentIndex: current.currentIndex + 1));
  }
}