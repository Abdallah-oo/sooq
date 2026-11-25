/// Server-calculated pricing for the current cart (`quote_order` RPC).
class OrderQuote {
  const OrderQuote({
    required this.subtotal,
    required this.discountPercent,
    required this.discountAmount,
    required this.deliveryFee,
    required this.total,
    required this.freeDeliveryThreshold,
    this.promoCode,
  });

  final double subtotal;
  final double discountPercent;
  final double discountAmount;
  final double deliveryFee;
  final double total;
  final double freeDeliveryThreshold;

  /// The promo code the server accepted (null when none is applied).
  final String? promoCode;

  factory OrderQuote.fromJson(Map<String, dynamic> json) {
    return OrderQuote(
      subtotal: (json['subtotal'] as num).toDouble(),
      discountPercent: (json['discount_percent'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      freeDeliveryThreshold: (json['free_delivery_threshold'] as num).toDouble(),
      promoCode: json['promo_code'] as String?,
    );
  }

  /// How much more the customer must add to get free delivery (0 when free).
  double get remainingForFreeDelivery {
    if (deliveryFee <= 0) return 0;
    final remaining = freeDeliveryThreshold - (subtotal - discountAmount);
    return remaining > 0 ? remaining : 0;
  }
}
