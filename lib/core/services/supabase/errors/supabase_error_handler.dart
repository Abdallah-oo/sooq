import 'dart:async';
import 'dart:io';

import 'package:sooq/core/services/supabase/errors/supabase_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseErrorHandler {
  static SupabaseError handleSupabaseError(Object e) {
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
    }

    if (e is SocketException) {
      return SupabaseError(message: 'No internet connection');
    }

    if (e is TimeoutException) {
      return SupabaseError(message: 'Request timeout, try again');
    }

    return SupabaseError(message: 'Unexpected error occurred');
  }

}
