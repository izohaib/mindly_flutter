import 'package:drift/drift.dart';
import 'package:mindly/core/database/app_database.dart';

class MockData {
  static List<LinksCompanion> get initialLinks => [
    LinksCompanion.insert(
      url: 'https://www.youtube.com/watch?v=jfKfPfyJRdk',
      title: Value('lofi hip hop radio - beats to relax/study to'),
      imageUrl: Value('https://images.unsplash.com/photo-1516280440614-37939bbacd81?q=80&w=1000&auto=format&fit=crop'),
      platform: Value('youtube'),
      imageWidth: const Value(1000),
      imageHeight: const Value(667),
    ),
    LinksCompanion.insert(
      url: 'https://www.reddit.com/r/ArchitecturePorn/',
      title: Value('Modern Architecture | The Interlace Singapore'),
      imageUrl: Value('https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=1000&auto=format&fit=crop'),
      platform: Value('reddit'),
      imageWidth: const Value(1000),
      imageHeight: const Value(1500),
    ),
    LinksCompanion.insert(
      url: 'https://flutter.dev',
      title: Value('Flutter - Build apps for any screen'),
      imageUrl: Value('https://images.unsplash.com/photo-1517694712202-14dd9538aa97?q=80&w=1000&auto=format&fit=crop'),
      platform: Value('other'),
      imageWidth: const Value(1000),
      imageHeight: const Value(667),
    ),
    LinksCompanion.insert(
      url: 'https://vimeo.com/channels/staffpicks',
      title: Value('Cinematic Landscapes - Staff Picks'),
      imageUrl: Value('https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1000&auto=format&fit=crop'),
      platform: Value('vimeo'),
      imageWidth: const Value(1000),
      imageHeight: const Value(667),
    ),
  ];
}
