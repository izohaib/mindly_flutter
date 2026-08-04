import 'package:flutter/material.dart';
import 'package:mindly/core/database/app_database.dart';
import '../data/link_repository.dart';


final AppDatabase appDatabase = AppDatabase();
final LinkRepository linkRepository = LinkRepository(appDatabase);


class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Stream<List<Link>> _linksStream;

  @override
  void initState() {
    super.initState();
    _linksStream = appDatabase.select(appDatabase.links).watch();
  }



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Link>>(
      stream: _linksStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final links = snapshot.data!;
        if (links.isEmpty) {
          return const Center(child: Text('No links saved yet'));
        }
        return ListView.builder(
          itemCount: links.length,
          itemBuilder: (context, index) {
            final link = links[index];
            return ListTile(
              title: Text(link.url),
              subtitle: Text(link.createdAt.toString()),
            );
          },
        );
      },
    );
  }
}