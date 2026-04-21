import 'package:flutter/material.dart';
import 'package:sooq/features/Auth/presentation/views/Signup_Views/signup_view_body.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: const Scaffold(body: SignupViewBody()),
    );
  }
}
