part of 'checkout_cubit.dart';

class CheckoutState {
  const CheckoutState({
    this.isLoading = true,
    this.loadError,
    this.address,
    this.quote,
    this.paymentMethod = PaymentMethod.cod,
    this.promoError,
    this.isUpdatingQuote = false,
    this.isPlacing = false,
    this.placeError,
    this.placedOrder,
  });

  /// First load (address + quote).
  final bool isLoading;
  final String? loadError;

  final AddressModel? address;

  /// Authoritative totals from the server (null only while loading / on load error).
  final OrderQuote? quote;
  final PaymentMethod paymentMethod;

  /// Promo apply / remove in flight.
  final bool isUpdatingQuote;
  final String? promoError;

  final bool isPlacing;

  /// Transient error shown as a snackbar.
  final String? placeError;

  /// Set once the order was created.
  final OrderModel? placedOrder;

  /// Kept when omitted: address, quote, paymentMethod, placedOrder.
  /// Reset when omitted: loadError, promoError, placeError (same convention as `HomeState`).
  CheckoutState copyWith({
    bool? isLoading,
    AddressModel? address,
    OrderQuote? quote,
    PaymentMethod? paymentMethod,
    bool? isUpdatingQuote,
    String? promoError,
    bool? isPlacing,
    String? placeError,
    OrderModel? placedOrder,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      address: address ?? this.address,
      quote: quote ?? this.quote,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isUpdatingQuote: isUpdatingQuote ?? this.isUpdatingQuote,
      promoError: promoError,
      isPlacing: isPlacing ?? this.isPlacing,
      placeError: placeError,
      placedOrder: placedOrder ?? this.placedOrder,
    );
  }
}
