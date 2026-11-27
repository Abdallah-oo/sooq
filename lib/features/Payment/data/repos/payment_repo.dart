import 'package:dartz/dartz.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error.dart';
import 'package:sooq/features/Payment/data/models/payment_session.dart';

abstract interface class PaymentRepo {
  /// Asks the server for a checkout session for [orderId]. The amount is read
  /// from the order on the server, never sent by the app.
  Future<Either<SupabaseError, PaymentSession>> createSession(String orderId);
}
