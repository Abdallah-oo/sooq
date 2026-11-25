import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/features/Address/data/models/address_model.dart';
import 'package:sooq/features/Address/data/repos/address_repo.dart';
import 'package:sooq/features/Cart/data/models/cart_item.dart';
import 'package:sooq/features/Orders/data/models/order_enums.dart';
import 'package:sooq/features/Orders/data/models/order_model.dart';
import 'package:sooq/features/Orders/data/models/order_quote.dart';
import 'package:sooq/features/Orders/data/repos/order_repo.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required OrderRepo orderRepo,
    required AddressRepo addressRepo,
    required List<CartItem> items,
  }) : _orderRepo = orderRepo,
       _addressRepo = addressRepo,
       _items = items,
       super(const CheckoutState());

  final OrderRepo _orderRepo;
  final AddressRepo _addressRepo;

  /// Snapshot of the cart when checkout opened.
  final List<CartItem> _items;

  /// Loads the default address and the server-priced quote in parallel.
  Future<void> init() async {
    emit(const CheckoutState());

    final addressFuture = _addressRepo.getAddresses();
    final quoteFuture = _orderRepo.quote(items: _items);
    final addressResult = await addressFuture;
    final quoteResult = await quoteFuture;

    final String? error = quoteResult.fold<String?>(
      (e) => e.message,
      (_) => addressResult.fold<String?>((e) => e.message, (_) => null),
    );
    if (error != null) {
      emit(CheckoutState(isLoading: false, loadError: error));
      return;
    }

    final List<AddressModel> addresses = addressResult.fold(
      (_) => const <AddressModel>[],
      (list) => list,
    );
    final OrderQuote? quote = quoteResult.fold((_) => null, (q) => q);

    emit(
      CheckoutState(
        isLoading: false,
        quote: quote,
        address: addresses.where((a) => a.isDefault).firstOrNull ?? addresses.firstOrNull,
      ),
    );
  }

  void selectAddress(AddressModel address) => emit(state.copyWith(address: address));

  void selectPaymentMethod(PaymentMethod method) =>
      emit(state.copyWith(paymentMethod: method));

  Future<void> applyPromo(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty || state.isUpdatingQuote || state.isPlacing) return;

    emit(state.copyWith(isUpdatingQuote: true));
    final result = await _orderRepo.quote(items: _items, promoCode: trimmed);
    result.fold(
      (e) => emit(state.copyWith(isUpdatingQuote: false, promoError: e.message)),
      (quote) => emit(state.copyWith(isUpdatingQuote: false, quote: quote)),
    );
  }

  Future<void> removePromo() async {
    if (state.isUpdatingQuote || state.isPlacing) return;

    emit(state.copyWith(isUpdatingQuote: true));
    final result = await _orderRepo.quote(items: _items);
    result.fold(
      (e) => emit(state.copyWith(isUpdatingQuote: false, promoError: e.message)),
      (quote) => emit(state.copyWith(isUpdatingQuote: false, quote: quote)),
    );
  }

  Future<void> placeOrder() async {
    final address = state.address;
    final quote = state.quote;
    if (address == null || quote == null || state.isPlacing || state.isUpdatingQuote) return;

    emit(state.copyWith(isPlacing: true));

    final result = await _orderRepo.placeOrder(
      items: _items,
      addressId: address.id,
      paymentMethod: state.paymentMethod,
      expectedTotal: quote.total,
      promoCode: quote.promoCode,
    );

    await result.fold(
      (e) async {
        emit(state.copyWith(isPlacing: false, placeError: e.message));
        // Typical cause: prices changed. Show the customer the new totals.
        await _refreshQuote();
      },
      (order) async => emit(state.copyWith(isPlacing: false, placedOrder: order)),
    );
  }

  Future<void> _refreshQuote() async {
    final result = await _orderRepo.quote(items: _items, promoCode: state.quote?.promoCode);
    result.fold(
      (_) {}, // keep what is on screen; the next action will report the problem
      // placeError is passed again because copyWith resets errors by default
      (quote) => emit(state.copyWith(quote: quote, placeError: state.placeError)),
    );
  }
}
