import 'package:dartz/dartz.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error_handler.dart';
import 'package:sooq/features/Cart/data/models/cart_item.dart';
import 'package:sooq/features/Orders/data/models/order_enums.dart';
import 'package:sooq/features/Orders/data/models/order_model.dart';
import 'package:sooq/features/Orders/data/models/order_quote.dart';
import 'package:sooq/features/Orders/data/repos/order_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRepoImpl implements OrderRepo {
  OrderRepoImpl(this._client);

  final SupabaseClient _client;

  static const String _ordersTable = 'orders';
  static const String _ordersWithItems = '*, order_items(*)';

  /// Only ids and quantities leave the device: prices are decided by the server.
  List<Map<String, dynamic>> _payload(List<CartItem> items) => [
    for (final item in items) {'product_id': item.product.id, 'quantity': item.quantity},
  ];

  String? _cleanCode(String? code) {
    final trimmed = code?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  @override
  Future<Either<SupabaseError, OrderQuote>> quote({
    required List<CartItem> items,
    String? promoCode,
  }) async {
    try {
      final response = await _client.rpc(
        'quote_order',
        params: {'p_items': _payload(items), 'p_promo_code': _cleanCode(promoCode)},
      );
      return Right(OrderQuote.fromJson(Map<String, dynamic>.from(response as Map)));
    } catch (e) {
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }

  @override
  Future<Either<SupabaseError, OrderModel>> placeOrder({
    required List<CartItem> items,
    required String addressId,
    required PaymentMethod paymentMethod,
    required double expectedTotal,
    String? promoCode,
  }) async {
    try {
      final response = await _client.rpc(
        'place_order',
        params: {
          'p_items': _payload(items),
          'p_address_id': addressId,
          'p_payment_method': paymentMethod.dbValue,
          'p_expected_total': expectedTotal,
          'p_promo_code': _cleanCode(promoCode),
        },
      );
      return Right(OrderModel.fromJson(Map<String, dynamic>.from(response as Map)));
    } catch (e) {
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }

  @override
  Future<Either<SupabaseError, List<OrderModel>>> getOrders() async {
    try {
      final response = await _client
          .from(_ordersTable)
          .select(_ordersWithItems)
          .order('created_at', ascending: false);

      final orders = (response as List)
          .map((row) => OrderModel.fromJson(Map<String, dynamic>.from(row as Map)))
          .toList();
      return Right(orders);
    } catch (e) {
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }

  @override
  Future<Either<SupabaseError, OrderModel>> getOrder(String id) async {
    try {
      final row = await _client.from(_ordersTable).select(_ordersWithItems).eq('id', id).single();
      return Right(OrderModel.fromJson(row));
    } catch (e) {
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }

  @override
  Future<Either<SupabaseError, OrderModel>> cancelOrder(String id) async {
    try {
      await _client.rpc('cancel_order', params: {'p_order_id': id});
      // cancel_order returns the order without items: reload the full order.
      return await getOrder(id);
    } catch (e) {
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }
}
