import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/utils/snack_bar.dart';
import 'package:sooq/features/Auth/presentation/cubits/Auth_Cubit/auth_cubit.dart';
import 'package:sooq/features/Auth/presentation/views/widgets/login_container.dart';

class LoginViewBody extends StatelessWidget {
  const LoginViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
          CustomSnackBar.error(context, state.errorMessage ?? '');
        }
        if (state.status == AuthStatus.success) {
          context.pushReplacement(Routes.root);
          CustomSnackBar.success(context, 'Login Successfully');
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            Image.asset('assets/img/logo/logo.png', height: 200),

            const Expanded(child: LoginContainer()),
          ],
        ),
      ),
    );
  }
}
