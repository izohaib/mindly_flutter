import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/sharing/share_intent_listener.dart';
import 'feature/feed/data/link_repository.dart';

void main() {
  final db = AppDatabase();
  final linkRepository = LinkRepository(db);

  runApp(
      ShareIntentListener(
        linkRepo: linkRepository,
        child: MyApp()
      )
  );
}
