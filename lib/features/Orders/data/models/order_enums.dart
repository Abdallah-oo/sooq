enum OrderStatus {
  pending('pending', 'Pending'),
  confirmed('confirmed', 'Confirmed'),
  preparing('preparing', 'Preparing'),
  outForDelivery('out_for_delivery', 'Out for delivery'),
  delivered('delivered', 'Delivered'),
  cancelled('cancelled', 'Cancelled');

  const OrderStatus(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static OrderStatus fromDb(String? value) => OrderStatus.values.firstWhere(
    (status) => status.dbValue == value,
    orElse: () => OrderStatus.pending,
  );
}

enum PaymentMethod {
  cod('cod', 'Cash on delivery', true),
  card('card', 'Card', false);

  const PaymentMethod(this.dbValue, this.label, this.isAvailable);

  final String dbValue;
  final String label;

  /// Methods the checkout screen offers (Card arrives with the Paymob phase).
  final bool isAvailable;

  static PaymentMethod fromDb(String? value) => PaymentMethod.values.firstWhere(
    (method) => method.dbValue == value,
    orElse: () => PaymentMethod.cod,
  );
}

enum PaymentStatus {
  unpaid('unpaid', 'Unpaid'),
  paid('paid', 'Paid'),
  failed('failed', 'Failed'),
  refunded('refunded', 'Refunded');

  const PaymentStatus(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static PaymentStatus fromDb(String? value) => PaymentStatus.values.firstWhere(
    (status) => status.dbValue == value,
    orElse: () => PaymentStatus.unpaid,
  );
}
