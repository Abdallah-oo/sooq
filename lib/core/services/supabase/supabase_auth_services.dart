
import 'dart:async';
import 'dart:io';

import 'package:sooq/core/services/supabase/errors/supabase_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient client;

  AuthService(this.client);

  Future<User> logIn(String email, String password) async {
    try {
      final res = await client.auth.signInWithPassword(email: email, password: password);
      return res.user!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> signUp(String email, String password) async {
    try {
      final res = await client.auth.signUp(email: email, password: password);
      return res.user!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw _handleError(e);
    }
  }

  User? get currentUser => client.auth.currentUser;
  SupabaseError _handleError(Object e) {
    if (e is AuthException) {
      final msg = e.message.toLowerCase();

      if (msg.contains('invalid login credentials')) {
        return SupabaseError(message: 'Email or password is incorrect');
      }

      if (msg.contains('already registered')) {
        return SupabaseError(message: 'Email already exists');
      }

      if (e.statusCode == '429') {
        return SupabaseError(message: 'Too many attempts, try again later');
      }

      if (msg.contains('jwt expired')) {
        return SupabaseError(message: 'Session expired, login again');
      }

      return SupabaseError(message: e.message);
    } else if (e is SocketException) {
      return SupabaseError(message: 'No internet connection');
    } else if (e is TimeoutException) {
      return SupabaseError(message: 'Request timeout, try again');
    } else {
      return SupabaseError(message: 'Unexpected error occurred');
    }
  }
}
