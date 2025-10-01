import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:market_salla/screens/Registration/login.dart';
import 'package:market_salla/screens/Registration/verifyemail.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Force a token refresh to check if the user is still valid on the server.
    FirebaseAuth.instance.currentUser?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show a loading indicator while checking the auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If a user is logged in (and still exists on the server)
          if (snapshot.hasData) {
            return const Verifyemail();
          }

          // If no user is logged in
          return const Login();
        },
      ),
    );
  }
}