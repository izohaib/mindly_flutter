import 'package:mindly/core/database/app_database.dart';

sealed class FeedState {
  const FeedState();
}

class FeedInitial extends FeedState {
  const FeedInitial();
}

class FeedLoading extends FeedState {
  const FeedLoading();
}

class FeedSuccess extends FeedState {
  final List<Link> links;
  final String searchQuery;
  final bool isSearching;
  final String? selectedFilter;

  const FeedSuccess({
    required this.links,
    this.searchQuery = '',
    this.isSearching = false,
    this.selectedFilter,
  });

  List<Link> get filteredLinks {
    if (searchQuery.isEmpty) return links;

    return links.where((link) {
      return (link.title ?? '')
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();
  }

  FeedSuccess copyWith({
    List<Link>? links,
    String? searchQuery,
    bool? isSearching,
    String? selectedFilter,
  }) {
    return FeedSuccess(
      links: links ?? this.links,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class FeedError extends FeedState {
  final String message;

  const FeedError(this.message);
}