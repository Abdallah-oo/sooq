import 'package:flutter/material.dart';
import 'package:sooq/core/routing/app_router.dart';
import 'package:sooq/core/theme/app_colors.dart';



class SooqApp extends StatelessWidget {
  const SooqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        splashColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.background),
      ),
      routerConfig: AppRouter.router,
         
    );
  }
}
