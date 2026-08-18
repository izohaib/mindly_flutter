import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mindly/app/scaffold/app_scaffold.dart';
import 'package:mindly/core/database/app_database.dart';
import 'package:mindly/core/router/route_constants.dart';
import '../../feature/feed/presentation/link_detail_screen.dart';
import '../../feature/feed/presentation/feed_screen.dart';
import '../../feature/shelves/presentation/folder_details_screen.dart';
import '../../feature/shelves/presentation/folders_screen.dart';
import '../../feature/sift/presentation/sift_screen.dart';
import '../../feature/splash/presentation/splash_screen.dart';

final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  final sideMenuNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteConstants.splash,
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.feed,
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.folder,
                builder: (context, state) => const ShelvesScreen(),
              ),
              GoRoute(
                path: RouteConstants.folderDetail,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>;
                  final folderId = extra['folderId'];
                  final folderName = extra['folderName'];

                  return FolderDetailScreen(folderId: folderId, folderName: folderName);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.sift,
                builder: (context, state) => const SiftScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: RouteConstants.linkDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final link = state.extra as Link;
          return LinkDetailScreen(link: link);
        },
      ),
    ],
  );
}