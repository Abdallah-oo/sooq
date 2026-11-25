import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseErrorHandler {
  /// Codes raised by the SQL functions (see supabase/migrations) -> user messages.
  static const Map<String, String> _businessMessages = {
    'NOT_AUTHENTICATED': 'Please login first',
    'EMPTY_CART': 'Your cart is empty',
    'INVALID_ITEMS': 'Some items in your cart are invalid',
    'PRODUCT_UNAVAILABLE': 'Some products are no longer available, please review your cart',
    'ADDRESS_NOT_FOUND': 'Please choose a delivery address',
    'ADDRESS_PHONE_REQUIRED': 'Add a phone number to your delivery address',
    'PROMO_INVALID': 'Invalid or expired promo code',
    'PROMO_MIN_ORDER': 'Your order does not reach the minimum amount for this code',
    'PRICE_CHANGED': 'Prices have changed, please review your order',
    'PAYMENT_METHOD_UNSUPPORTED': 'This payment method is not available yet',
    'ORDER_NOT_FOUND': 'Order not found',
    'ORDER_NOT_CANCELLABLE': 'This order can no longer be cancelled',
  };

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
        case 'PGRST116': // .single() found no row
          return SupabaseError(message: 'Item not found');
        case 'P0001': // raise exception 'CODE' inside our SQL functions
          return SupabaseError(
            message: _businessMessages[e.message] ?? 'Something went wrong, please try again',
          );
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
