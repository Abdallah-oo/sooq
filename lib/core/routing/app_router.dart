import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/utils/di/get_it.dart';
import 'package:sooq/features/Auth/data/repos/auth_repo_impl.dart';
import 'package:sooq/features/Auth/presentation/views/Login_Views/login_view.dart';
import 'package:sooq/features/Auth/presentation/views/Signup_Views/signup_view.dart';
import 'package:sooq/features/Auth/presentation/views/cubits/Auth_Cubit/auth_cubit.dart';
import 'package:sooq/features/Auth/presentation/views/cubits/Pick_Image_Cubit/pick_image_cubit.dart';
import 'package:sooq/features/Cart/presentation/cubits/cart_cubit.dart';
import 'package:sooq/features/Cart/presentation/views/cart_view.dart';
import 'package:sooq/features/Favorite/data/repos/favorites_repo.dart';
import 'package:sooq/features/Favorite/presentation/cubit/favorites_cubit.dart';
import 'package:sooq/features/Home/presentation/cubits/category_cubit.dart';
import 'package:sooq/features/On_Boarding/presentation/views/onboarding_view.dart';
import 'package:sooq/root.dart';


abstract class AppRouter {
  static final router = GoRouter(
    routes: [
      //initial (login)
      GoRoute(path: '/', builder: (context, state) => const OnboardingView()),

      //login
      GoRoute(
        path: Routes.login,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: BlocProvider(
            create: (context) => AuthCubit(getIt<AuthRepoImpl>()),
            child: const LoginView(),
          ),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),

      //signup
      GoRoute(
        path: Routes.signup,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => AuthCubit(getIt<AuthRepoImpl>()),
              ),
              BlocProvider(create: (context) => PickImageCubit()),
            ],
            child: const SignupView(),
          ),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),

      //root
      GoRoute(
        path: Routes.root,

        pageBuilder: (context, state) => CustomTransitionPage(
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => CartCubit()),
              BlocProvider(create: (_) => CategoryCubit()),
              BlocProvider(
                create: (context) =>
                    FavoritesCubit(FavoritesRepository())..init(),
              ),
            ],
            child: const Root(),
          ),

          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),

      //cart
      GoRoute(
        path: Routes.cart,
        pageBuilder: (_, state) {
          final BuildContext context = state.extra as BuildContext;
          return CustomTransitionPage(
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<CartCubit>()),
            BlocProvider.value(value: context.read<FavoritesCubit>()),
              ],
              child: const CartView(),
            ),
            transitionsBuilder: (context, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          );
        },
      ),
    ],
  );
}
