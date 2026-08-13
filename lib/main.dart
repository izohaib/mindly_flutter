import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/sharing/share_intent_listener.dart';
import 'feature/feed/data/link_repository.dart';

void main() {
  runApp(
      ShareIntentListener(
        linkRepo: LinkRepository.instance,
        child: MyApp()
      )
  );
}

