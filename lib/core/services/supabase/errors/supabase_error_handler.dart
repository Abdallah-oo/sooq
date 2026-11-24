import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
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

    if (e is PostgrestException) {
      debugPrint('PostgrestException(${e.code}): ${e.message}');

      switch (e.code) {
        case '42501': // RLS / permission denied
          return SupabaseError(message: 'You are not allowed to do this action');
        case '23505': // unique violation
          return SupabaseError(message: 'This item already exists');
        case '23503': // foreign key violation
          return SupabaseError(message: 'Related data was not found');
        case '23514': // check constraint
        case '22001': // value too long
          return SupabaseError(message: 'Some of the entered data is invalid');
        case 'PGRST301': // JWT expired / invalid
          return SupabaseError(message: 'Session expired, login again');
      }
      return SupabaseError(message: 'Something went wrong, please try again');
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
