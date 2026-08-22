import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindly/feature/splash/presentation/splash_screen.dart';
import 'package:mindly/feature/animation_samples/presentation/animation_practice_screen.dart';
import '../core/router/app_router.dart';
import '../core/theme/theme.dart';
import '../feature/feed/data/link_repository.dart';
import '../feature/feed/presentation/bloc/feed_cubit.dart';
import '../feature/shelves/data/folders_repository.dart';
import '../feature/shelves/presentation/bloc/folders_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FeedCubit(LinkRepository.instance)),
        BlocProvider(create: (_) => FoldersCubit(FoldersRepository.instance)),
      ],

      // child: MaterialApp(
      //   debugShowCheckedModeBanner: false,
      //   theme: AppTheme.theme,
      //   home: AnimationLearning(),
      // ),

      child: MaterialApp.router(
        scaffoldMessengerKey: appScaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'Mindly',
        theme: AppTheme.theme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}