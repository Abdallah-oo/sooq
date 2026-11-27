/// Result of the `create-payment` Edge Function.
class PaymentSession {
  const PaymentSession({required this.checkoutUrl, required this.returnUrl});

  /// Paymob hosted checkout page (card / wallet details are typed there).
  final String checkoutUrl;

  /// URL Paymob redirects to when the customer finishes. The WebView intercepts
  /// it: it is only a signal to check the order, never proof of payment.
  final String returnUrl;

  factory PaymentSession.fromJson(Map<String, dynamic> json) {
    return PaymentSession(
      checkoutUrl: json['checkout_url'] as String,
      returnUrl: json['return_url'] as String,
    );
  }
}
