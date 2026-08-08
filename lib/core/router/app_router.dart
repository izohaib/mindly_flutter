import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mindly/app/scaffold/app_scaffold.dart';
import 'package:mindly/core/database/app_database.dart';
import 'package:mindly/core/router/route_constants.dart';
import 'package:mindly/feature/feed/data/link_repository.dart';
import 'package:mindly/feature/feed/presentation/bloc/feed_cubit.dart';
import 'package:mindly/feature/shelves/data/folders_repository.dart';
import 'package:mindly/feature/shelves/presenation/bloc/folders_cubit.dart';
import '../../feature/feed/link_detail_screen.dart';
import '../../feature/feed/presentation/feed_screen.dart';
import '../../feature/shelves/presenation/folder_details_screen.dart';
import '../../feature/shelves/presenation/folders_screen.dart';
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
                builder: (context, state) => BlocProvider(
                  create: (_) => FeedCubit(LinkRepository.instance),
                  child: const FeedScreen(),
                ),
              ),

              GoRoute(
                path: RouteConstants.linkDetail,
                builder: (context, state) {
                  final link = state.extra as Link;
                  return LinkDetailScreen(link: link);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              ShellRoute(
                builder: (context, state, child) => BlocProvider(
                  create: (_) => FoldersCubit(FoldersRepository.instance),
                  child: child,
                ),
                routes: [
                  GoRoute(
                    path: RouteConstants.folder,
                    builder: (context, state) => const ShelvesScreen(),
                  ),
                  GoRoute(
                    path: RouteConstants.folderDetail,
                    builder: (context, state) {
                      final folderId = state.extra as int;
                      return FolderDetailScreen(folderId: folderId);
                    },
                  ),
                ],
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
    ],
  );
}
