/// Single place that formats prices.
///
/// The server stores the currency code in `app_settings.currency_code`.
/// When the app moves to EGP (Paymob phase) change [symbol] here only.
abstract final class Money {
  static const String symbol = 'EGP';

  static String format(num value) => '$symbol${value.toStringAsFixed(2)}';
}
