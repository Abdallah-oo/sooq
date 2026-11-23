import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/core/routing/app_router.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/features/Cart/presentation/cubits/cart_cubit.dart';
import 'package:sooq/features/Favorite/data/repos/favorites_repo.dart';
import 'package:sooq/features/Favorite/presentation/cubit/favorites_cubit.dart';

class SooqApp extends StatelessWidget {
  const SooqApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cart & Favorites live above the router so every route (cart, checkout,
    // category products, ...) can read them without passing cubits around.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CartCubit()),
        BlocProvider(create: (_) => FavoritesCubit(FavoritesRepositoryImpl())..init()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Sooq',
        theme: ThemeData(
          splashColor: Colors.transparent,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.background),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
