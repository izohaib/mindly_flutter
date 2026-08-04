import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();

    // App already running (foreground/background) when share happens
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((sharedFiles) {
      if (sharedFiles.isNotEmpty) {
        widget.linkRepo.saveLink(sharedFiles.first.path);
        print("Shared while running: ${sharedFiles.first.path}");
      }
    }, onError: (err) {
      print("getMediaStream error: $err");
    });

    // App launched fresh via share (cold start)
    ReceiveSharingIntent.instance.getInitialMedia().then((sharedFiles) {
      if (sharedFiles.isNotEmpty) {
        widget.linkRepo.saveLink(sharedFiles.first.path);
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