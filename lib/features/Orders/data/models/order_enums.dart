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
  cod('cod', 'Cash on delivery', 'Pay in cash when your order arrives', false),
  card('card', 'Credit / debit card', 'Pay securely with your bank card', true),
  wallet('wallet', 'Mobile wallet', 'Pay with your mobile wallet number', true);

  const PaymentMethod(this.dbValue, this.label, this.description, this.isOnline);

  final String dbValue;
  final String label;
  final String description;

  /// Paid through Paymob (card / wallet) instead of cash on delivery.
  final bool isOnline;

  /// Paymob charges in EGP only, so online methods exist only in that currency.
  bool isAvailableIn(String currencyCode) => !isOnline || currencyCode.toUpperCase() == 'EGP';

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
