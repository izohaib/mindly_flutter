import 'package:flutter/material.dart';
import 'package:mindly/core/services/metadata_service.dart';
import 'package:mindly/feature/feed/data/link_repository.dart';
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareIntentListener extends StatefulWidget {
  final Widget child;
  final LinkRepository linkRepo ;

  const ShareIntentListener({super.key, required this.child, required this.linkRepo});

  @override
  State<ShareIntentListener> createState() => _ShareIntentListenerState();
}

class _ShareIntentListenerState extends State<ShareIntentListener> {
  StreamSubscription? _intentSub;

  // giving title and image
  final _metadataService = MetadataService();

  Future<void> _handleSharedLink(String url) async {
    final id = await widget.linkRepo.saveLink(url);
    final meta = await _metadataService.fetch(url);
    await widget.linkRepo.updateMetadata(id: id, title: meta.title, imageUrl: meta.imageUrl, imageHeight: meta.imageHeight, imageWidth: meta.imageWidth);
  }

  @override
  void initState() {
    super.initState();

    // App already running (foreground/background) when share happens
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((sharedFiles) {
      if (sharedFiles.isNotEmpty) {
        final url = sharedFiles.first.path;
        //getting value(url): sharedFiles.first.path
        _handleSharedLink(url);
        print("Shared while running: ${sharedFiles.first.path}");
      }
    }, onError: (err) {
      print("getMediaStream error: $err");
    });

    // App launched fresh via share (cold start)
    ReceiveSharingIntent.instance.getInitialMedia().then((sharedFiles) async{
      if (sharedFiles.isNotEmpty) {
        final url = sharedFiles.first.path;
        _handleSharedLink(url);
        print("Shared on cold start: ${sharedFiles.first.path}");
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