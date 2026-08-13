import 'package:flutter/material.dart';
import 'package:mindly/core/services/metadata_service.dart';
import 'package:mindly/feature/feed/data/link_repository.dart';
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../utils/platform_detector.dart';


class ShareIntentListener extends StatefulWidget {
  final Widget child;
  final LinkRepository linkRepo;

  const ShareIntentListener({
    super.key,
    required this.child,
    required this.linkRepo,
  });

  @override
  State<ShareIntentListener> createState() => _ShareIntentListenerState();
}

class _ShareIntentListenerState extends State<ShareIntentListener> {
  StreamSubscription? _intentSub;
  final _metadataService = MetadataService();

  /// Handle a shared link:
  /// 1. Detect platform (instant, from URL only)
  /// 2. Save link with platform to DB (fast sync operation)
  /// 3. Fetch metadata async in background (title, image)
  /// 4. Update metadata fields when ready
  Future<void> _handleSharedLink(String url) async {
    try {
      // Step 1: Detect platform immediately (no network, instant)
      final platform = PlatformDetector.detect(url);
      print('🔗 [ShareIntentListener] Detected platform: $platform');

      // Step 2: Save link with platform FIRST (this is fast, don't await metadata)
      final linkId = await widget.linkRepo.saveLink(
        url: url,
        platform: platform,
      );
      print('💾 [ShareIntentListener] Link saved immediately: ID=$linkId, platform=$platform');

      // Step 3 & 4: Fetch metadata and update in background (async, doesn't block)
      // User sees the link appear instantly, metadata loads in the background
      _fetchAndUpdateMetadataAsync(linkId, url);

    } catch (e) {
      print('❌ [ShareIntentListener] Error: $e');
    }
  }

  /// Fetch metadata async in background - doesn't block the save
  void _fetchAndUpdateMetadataAsync(int linkId, String url) async {
    try {
      print('📊 [ShareIntentListener] Fetching metadata in background for: $url');

      final meta = await _metadataService.fetch(url);

      print('📊 [ShareIntentListener] Metadata fetched - Title: ${meta.title}, Image: ${meta.imageUrl}');

      // Update metadata fields
      await widget.linkRepo.updateMetadata(
        id: linkId,
        title: meta.title,
        imageUrl: meta.imageUrl,
        imageHeight: meta.imageHeight,
        imageWidth: meta.imageWidth,
      );

      print('✅ [ShareIntentListener] Metadata updated for link: $linkId');
    } catch (e) {
      print('⚠️ [ShareIntentListener] Error fetching metadata: $e');
      // Don't crash - metadata is optional, link was already saved
    }
  }

  @override
  void initState() {
    super.initState();

    // Listen for shares while app is running (foreground/background)
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
          (sharedFiles) {
        if (sharedFiles.isNotEmpty) {
          final url = sharedFiles.first.path;
          _handleSharedLink(url);
          print("🔄 [ShareIntentListener] Shared while running: $url");
        }
      },
      onError: (err) {
        print("❌ [ShareIntentListener] getMediaStream error: $err");
      },
    );

    // Listen for shares when app is launched fresh (cold start)
    ReceiveSharingIntent.instance.getInitialMedia().then((sharedFiles) async {
      if (sharedFiles.isNotEmpty) {
        final url = sharedFiles.first.path;
        _handleSharedLink(url);
        print("🚀 [ShareIntentListener] Shared on cold start: $url");
      }
      ReceiveSharingIntent.instance.reset();
    });
  }

  @override
  void dispose() {
    _intentSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}