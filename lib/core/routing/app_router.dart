import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/config/map_config.dart';
import 'package:sooq/core/utils/di/get_it.dart';
import 'package:sooq/features/Address/data/repos/address_repo.dart';
import 'package:sooq/features/Address/data/services/geocoding_service.dart';
import 'package:sooq/features/Address/data/services/location_service.dart';
import 'package:sooq/features/Address/presentation/cubits/address_form_cubit/address_form_cubit.dart';
import 'package:sooq/features/Address/presentation/cubits/address_picker_cubit/address_picker_cubit.dart';
import 'package:sooq/features/Address/presentation/cubits/addresses_cubit/addresses_cubit.dart';
import 'package:sooq/features/Address/presentation/route_args/address_route_args.dart';
import 'package:sooq/features/Address/presentation/views/address_form_view.dart';
import 'package:sooq/features/Address/presentation/views/address_picker_view.dart';
import 'package:sooq/features/Address/presentation/views/addresses_view.dart';
import 'package:sooq/features/Auth/data/repos/auth_repo.dart';
import 'package:sooq/features/Auth/presentation/views/Login_Views/login_view.dart';
import 'package:sooq/features/Auth/presentation/views/Signup_Views/signup_view.dart';
import 'package:sooq/features/Auth/presentation/cubits/Auth_Cubit/auth_cubit.dart';
import 'package:sooq/features/Auth/presentation/cubits/Pick_Image_Cubit/pick_image_cubit.dart';
import 'package:sooq/features/Cart/presentation/views/cart_view.dart';
import 'package:sooq/features/Home/data/models/category_model.dart';
import 'package:sooq/features/Home/data/repos/home_repo/home_repo.dart';
import 'package:sooq/features/Home/presentation/cubits/category_cubit/category_cubit.dart';
import 'package:sooq/features/Home/presentation/cubits/home_cubit/home_cubit.dart';
import 'package:sooq/features/Home/presentation/views/category_products_view.dart';
import 'package:sooq/features/On_Boarding/presentation/views/onboarding_view.dart';
import 'package:sooq/root.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AppRouter {
  static CustomTransitionPage<T> _fadePage<T>(Widget child, {int milliseconds = 400}) {
    return CustomTransitionPage<T>(
      child: child,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: Duration(milliseconds: milliseconds),
    );
  }

  static final router = GoRouter(
    // Returning users with a live Supabase session skip onboarding/login.
    redirect: (context, state) {
      final hasSession = Supabase.instance.client.auth.currentSession != null;
      if (state.matchedLocation == '/' && hasSession) return Routes.root;
      return null;
    },
    routes: [
      //initial (login)
      GoRoute(path: '/', builder: (context, state) => const OnboardingView()),

      //login
      GoRoute(
        path: Routes.login,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: BlocProvider(
            create: (context) => AuthCubit(getIt<AuthRepo>()),
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
              BlocProvider(create: (context) => AuthCubit(getIt<AuthRepo>())),
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
              BlocProvider(create: (_) => CategoryCubit()),
              BlocProvider(create: (_) => HomeCubit(getIt<HomeRepo>())..fetchHomeData()),
              // Used by Profile -> Logout
              BlocProvider(create: (_) => AuthCubit(getIt<AuthRepo>())),
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
        pageBuilder: (_, state) => CustomTransitionPage(
          child: const CartView(),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      ),

      //addresses (pass `extra: true` for selection mode, e.g. from checkout)
      GoRoute(
        path: Routes.addresses,
        pageBuilder: (context, state) {
          final selectMode = (state.extra as bool?) ?? false;
          return _fadePage(
            BlocProvider(
              create: (_) => AddressesCubit(getIt<AddressRepo>())..fetchAddresses(),
              child: AddressesView(selectMode: selectMode),
            ),
          );
        },
      ),

      //address map picker
      GoRoute(
        path: Routes.addressPicker,
        pageBuilder: (context, state) {
          final args = state.extra as AddressPickerArgs;
          return _fadePage(
            BlocProvider(
              create: (_) => AddressPickerCubit(
                location: getIt<LocationService>(),
                geocoding: getIt<GeocodingService>(),
                initialCenter: args.editing?.location ?? MapConfig.defaultCenter,
              ),
              child: AddressPickerView(args: args),
            ),
          );
        },
      ),

      //address details form
      GoRoute(
        path: Routes.addressForm,
        pageBuilder: (context, state) {
          final args = state.extra as AddressFormArgs;
          return _fadePage(
            BlocProvider(
              create: (_) => AddressFormCubit(getIt<AddressRepo>()),
              child: AddressFormView(args: args),
            ),
          );
        },
      ),

      GoRoute(
        path: Routes.categoryProducts,
        pageBuilder: (context, state) {
          final params = state.extra as CategoryProductsViewParameters;
          return CustomTransitionPage(
            child: CategoryProductsView(params: params),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          );
        },
      ),
    ],
  );
}

class CategoryProductsViewParameters {
  final CategoryModel category;
  CategoryProductsViewParameters({required this.category});
}
