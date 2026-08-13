import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindly/feature/feed/data/link_repository.dart';
import 'package:mindly/core/database/app_database.dart';
import 'package:mindly/feature/feed/presentation/bloc/feed_state.dart';
import '../../../../core/services/metadata_service.dart';
import '../../../../core/utils/platform_detector.dart';


class FeedCubit extends Cubit<FeedState> {
  final LinkRepository linkRepository;
  final _metadataService = MetadataService();
  StreamSubscription? linksSubscription;

  FeedCubit(this.linkRepository) : super(const FeedInitial()) {
    _listenToAllLinkChanges();
  }

  void _listenToAllLinkChanges() {
    emit(const FeedLoading());

    linksSubscription = linkRepository.watchAllLinks().listen(
      (links) {
        final platforms = links
            .map((l) => l.platform)
            .whereType<String>()
            .toSet()
            .toList();

        emit(
          FeedSuccess(
            links: links,
            filteredPlatformLinks: links,
            platformLinks: links,
            availablePlatforms: platforms,
            selectedFilter: 'All',
            isSearching: false,
            searchQuery: '',
          ),
        );
      },
      onError: (e) {
        emit(FeedError(message: e.toString()));
      },
    );
  }


  /// Select a platform filter and show only links from that platform
  Future<void> selectFilter(String platform) async {
    try {
      if (state is! FeedSuccess) return;
      final currentState = state as FeedSuccess;

      emit(const FeedLoading());

      List<Link> filteredLinks;

      if (platform == 'All') {
        filteredLinks = currentState.links;
      } else {
        filteredLinks = await linkRepository.getLinksByPlatform(platform);
      }

      print('🔗 Filtered by $platform: ${filteredLinks.length} links');

      emit(
        currentState.copyWith(
          filteredPlatformLinks: filteredLinks,
          selectedFilter: platform,
          platformLinks: filteredLinks,
          isSearching: false,
        ),
      );
    } catch (e) {
      print('❌ Error filtering links: $e');
      emit(FeedError(message: e.toString()));
    }
  }

  void isSearching(bool isSearching) {
    if (state is! FeedSuccess) return;

    final currentState = state as FeedSuccess;

    emit(currentState.copyWith(isSearching: isSearching));
  }

  Future<void> search(String query) async {
    try {
      if (state is! FeedSuccess) return;
      final currentState = state as FeedSuccess;

      List<Link> filtered;

      if (query.isEmpty) {
        filtered = currentState.platformLinks;
      } else {
        filtered = currentState.platformLinks.where((link) {
          final titleMatch =
              link.title?.toLowerCase().contains(query.toLowerCase()) ?? false;
          final urlMatch = link.url.toLowerCase().contains(query.toLowerCase());
          return titleMatch || urlMatch;
        }).toList();
      }

      print('🔍 Search "$query" → ${filtered.length} results');

      emit(
        currentState.copyWith(
          filteredPlatformLinks: filtered,
          searchQuery: query,
        ),
      );
    } catch (e) {
      print('❌ Error searching: $e');
    }
  }

  Link? _lastDeletedLink;

  Future<void> deleteLink(int id) async {
    _lastDeletedLink = await linkRepository.getLinkById(id);
    await linkRepository.deleteLink(id);
  }

  Future<void> undoDelete() async {
    if (_lastDeletedLink == null) return;
    await linkRepository.restoreLink(_lastDeletedLink!);
    _lastDeletedLink = null;
  }

  Future<void> addLink(String url) async {
    try {
      final platform = PlatformDetector.detect(url);
      final linkId = await linkRepository.saveLink(
        url: url,
        platform: platform,
      );

      _fetchAndUpdateMetadataAsync(linkId, url);
    } catch (e) {
      print('❌ Error adding link: $e');
    }
  }

  void _fetchAndUpdateMetadataAsync(int linkId, String url) async {
    try {
      final meta = await _metadataService.fetch(url);
      await linkRepository.updateMetadata(
        id: linkId,
        title: meta.title,
        imageUrl: meta.imageUrl,
        imageHeight: meta.imageHeight,
        imageWidth: meta.imageWidth,
      );
    } catch (e) {
      print('⚠️ Error fetching metadata: $e');
    }
  }


  @override
  Future<void> close() {
    linksSubscription?.cancel();
    return super.close();
  }

}
