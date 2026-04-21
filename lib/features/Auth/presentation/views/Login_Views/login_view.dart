import 'package:flutter/material.dart';

import 'package:sooq/features/Auth/presentation/views/Login_Views/login_view_body.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: const Scaffold(body: LoginViewBody()),
    );
  }
}
