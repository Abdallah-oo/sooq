import 'package:dartz/dartz.dart';
import 'package:sooq/core/services/supabase/supabase_auth_services.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error.dart';
import 'package:sooq/features/Auth/data/repos/auth_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepoImpl implements AuthRepo {
  final AuthService _authService;

  AuthRepoImpl(this._authService);

  @override
  Future<Either<SupabaseError, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final respons = await _authService.logIn(email, password);
      return Right(respons);
    } catch (e) {
      return Left(SupabaseError(message: '$e'));
    }
  }

  @override
  Future<Either<SupabaseError, User>> signup({
    required String name,
    required String email,
    required String password,
  }) async{
   try {
      final respons = await _authService.signUp(email, password);
      return Right(respons);
    } catch (e) {
      return Left(SupabaseError(message: '$e'));
    }
  }
}
