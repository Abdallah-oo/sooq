import 'package:dartz/dartz.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error_handler.dart';
import 'package:sooq/features/Payment/data/models/payment_session.dart';
import 'package:sooq/features/Payment/data/repos/payment_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentRepoImpl implements PaymentRepo {
  PaymentRepoImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Either<SupabaseError, PaymentSession>> createSession(String orderId) async {
    try {
      final response = await _client.functions.invoke(
        'create-payment',
        body: {'order_id': orderId},
      );
      return Right(PaymentSession.fromJson(Map<String, dynamic>.from(response.data as Map)));
    } catch (e) {
      print('wallet error is : $e');
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }
}
