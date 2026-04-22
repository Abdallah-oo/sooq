import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/features/Auth/data/repos/auth_repo.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.authRepo) : super(AuthState.initial());
  final AuthRepo authRepo;
  //login btn cubit
  Future<void> onTapLoginBut({
    required String email,
    required String password,
  }) async {
    if (state.status == AuthStatus.loading) return;

    emit(const AuthState(action: AuthAction.login, status: AuthStatus.loading));

    final user = await authRepo.login(email: email, password: password);
    user.fold(
      (error) => emit(
        AuthState(
          action: AuthAction.login,
          status: AuthStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (_) =>
          emit(const AuthState(action: AuthAction.login, status: AuthStatus.success)),
    );
  }

  //SignUp cubit
  Future<void> onTapSignUpBut({
    required String name,
    required String email,
    required String password,
  }) async {
    if (state.status == AuthStatus.loading) return;

    emit(const AuthState(action: AuthAction.signup, status: AuthStatus.loading));

    final user = await authRepo.signup(
      name: name,
      email: email,
      password: password,
    );
    user.fold(
      (error) => emit(
        AuthState(
          action: AuthAction.signup,
          status: AuthStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (_) => emit(
        const AuthState(action: AuthAction.signup, status: AuthStatus.success),
      ),
    );
  }

}
