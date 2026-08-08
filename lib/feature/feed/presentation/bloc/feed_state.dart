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

final class FeedSuccess extends FeedState {
  final List<Link> links;
  final List<Link> platformLinks; // platform-filtered, for search query
  final List<Link> filteredPlatformLinks;  // for platform filtered chips
  final List<String> availablePlatforms;
  final String selectedFilter;
  final bool isSearching;
  final String searchQuery;

  const FeedSuccess({
    required this.links,
    required this.platformLinks,
    required this.filteredPlatformLinks,
    required this.availablePlatforms,
    required this.selectedFilter,
    required this.isSearching,
    required this.searchQuery,
  });

  FeedSuccess copyWith({
    List<Link>? links,
    List<Link>? platformLinks,
    List<Link>? filteredPlatformLinks,
    List<String>? availablePlatforms,
    String? selectedFilter,
    bool? isSearching,
    String? searchQuery,
  }) {
    return FeedSuccess(
      links: links ?? this.links,
      platformLinks: platformLinks ?? this.platformLinks,
      filteredPlatformLinks:
      filteredPlatformLinks ?? this.filteredPlatformLinks,
      availablePlatforms: availablePlatforms ?? this.availablePlatforms,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}


class FeedError extends FeedState {
  final String message;

  const FeedError({required this.message});
}