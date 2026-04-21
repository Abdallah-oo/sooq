import 'package:get_it/get_it.dart';
import 'package:sooq/core/supabase/supabase_auth_services.dart';
import 'package:sooq/core/supabase/supabase_client.dart';
import 'package:sooq/features/Auth/data/repos/auth_repo_impl.dart';

final getIt = GetIt.instance;

void setUpGetIt() {
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(SupabaseClientManager.client),
  );
  getIt.registerLazySingleton<AuthRepoImpl>(
    () => AuthRepoImpl(getIt<AuthService>()),
  );


}
