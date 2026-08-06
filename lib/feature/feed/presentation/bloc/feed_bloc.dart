import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindly/core/database/app_database.dart';
import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  final AppDatabase appDatabase;

  StreamSubscription<List<Link>>? _linksSubscription;

  FeedCubit({required this.appDatabase}) : super(const FeedInitial()) {
    _subscribeToLinks();
  }

  void _subscribeToLinks() {
    emit(const FeedLoading());

    _linksSubscription = appDatabase
        .select(appDatabase.links)
        .watch()
        .listen(
          (links) {
            emit(FeedSuccess(links: links));
          },
          onError: (error) {
            emit(FeedError(error.toString()));
          },
        );
  }

  void search(String query) {
    final current = state;

    if (current is FeedSuccess) {
      emit(current.copyWith(searchQuery: query));
    }
  }

  void setSearching(bool value) {
    final current = state;

    if (current is FeedSuccess) {
      emit(current.copyWith(isSearching: value));
    }
  }

  void selectFilter(String filter) {
    final current = state;

    if (current is FeedSuccess) {
      emit(current.copyWith(selectedFilter: filter));
    }
  }

  @override
  Future<void> close() {
    _linksSubscription?.cancel();
    return super.close();
  }
}
