import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'core/sharing/share_intent_listener.dart';
import 'feature/feed/data/link_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Make the status bar and navigation bar transparent for a seamless look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // For dark theme
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
      ShareIntentListener(
        linkRepo: LinkRepository.instance,
        child: MyApp()
      )
  );
}

