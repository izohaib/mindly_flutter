import 'package:flutter/material.dart';
import '../core/router/app_router.dart';
import '../core/theme/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.theme,
      routerConfig: AppRouter.router,
    );
  }
}