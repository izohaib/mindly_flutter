import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:mindly/app/scaffold/app_scaffold.dart';
import 'package:mindly/core/router/route_constants.dart';
import '../../feature/feed/presentation/feed_screen.dart';
import '../../feature/shelves/presenation/shelves_screen.dart';
import '../../feature/sift/presentation/sift_screen.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  final sideMenuNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteConstants.feed,
    routes: [
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
                path: RouteConstants.shelves,
                builder: (context, state) => const ShelvesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.shift,
                builder: (context, state) => const SiftScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
