import 'package:get_it/get_it.dart';
import 'package:sooq/core/services/supabase/supabase_auth_services.dart';
import 'package:sooq/core/services/supabase/supabase_client.dart';
import 'package:sooq/features/Auth/data/repos/auth_repo_impl.dart';
import 'package:sooq/features/Home/data/local/products_local_data_source.dart';
import 'package:sooq/features/Home/data/repos/category_product_repo/category_product_repo.dart';
import 'package:sooq/features/Home/data/repos/category_product_repo/category_product_repo_impl.dart';
import 'package:sooq/features/Home/data/repos/home_repo/home_repo.dart';
import 'package:sooq/features/Home/data/repos/home_repo/home_repo_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

void setUpGetIt() {
  getIt.registerLazySingleton<SupabaseClient>(() => SupabaseClientManager.client);
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt<SupabaseClient>()));
  getIt.registerLazySingleton<AuthRepoImpl>(() => AuthRepoImpl(getIt<AuthService>()));
  getIt.registerLazySingleton<HomeRepo>(() => HomeRepoImpl(getIt<SupabaseClient>()));
  getIt.registerLazySingleton<CategoryProductsRepo>(
    () => CategoryProductRepoImpl(getIt<SupabaseClient>(), ProductsLocalDataSource()),
  );
}
