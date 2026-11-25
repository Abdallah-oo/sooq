import 'package:dartz/dartz.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error.dart';
import 'package:sooq/features/Cart/data/models/cart_item.dart';
import 'package:sooq/features/Orders/data/models/order_enums.dart';
import 'package:sooq/features/Orders/data/models/order_model.dart';
import 'package:sooq/features/Orders/data/models/order_quote.dart';

abstract interface class OrderRepo {
  /// Server-side pricing (prices, promo code, delivery fee) for [items].
  Future<Either<SupabaseError, OrderQuote>> quote({
    required List<CartItem> items,
    String? promoCode,
  });

  /// [expectedTotal] is what the customer saw; the server rejects the order
  /// if the real total differs (price changed meanwhile).
  Future<Either<SupabaseError, OrderModel>> placeOrder({
    required List<CartItem> items,
    required String addressId,
    required PaymentMethod paymentMethod,
    required double expectedTotal,
    String? promoCode,
  });

  /// Newest first, with their items.
  Future<Either<SupabaseError, List<OrderModel>>> getOrders();

  Future<Either<SupabaseError, OrderModel>> getOrder(String id);

  Future<Either<SupabaseError, OrderModel>> cancelOrder(String id);
}
