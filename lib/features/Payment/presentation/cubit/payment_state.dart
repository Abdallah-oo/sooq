part of 'payment_cubit.dart';

enum PaymentFlowStatus {
  /// Asking the server for a checkout session.
  creating,

  /// Paymob page is on screen.
  awaiting,

  /// Customer came back: waiting for the webhook to update the order.
  verifying,
  paid,
  failed,

  /// The webhook has not arrived yet; the order will update on its own.
  timeout,

  /// The checkout session could not be created.
  error,
}

class PaymentState {
  const PaymentState({
    required this.order,
    this.status = PaymentFlowStatus.creating,
    this.session,
    this.errorMessage,
  });

  /// Latest known version of the order.
  final OrderModel order;
  final PaymentFlowStatus status;
  final PaymentSession? session;
  final String? errorMessage;

  PaymentState copyWith({
    OrderModel? order,
    PaymentFlowStatus? status,
    PaymentSession? session,
    String? errorMessage,
  }) {
    return PaymentState(
      order: order ?? this.order,
      status: status ?? this.status,
      session: session ?? this.session,
      errorMessage: errorMessage,
    );
  }
}
