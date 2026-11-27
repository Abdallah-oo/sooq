import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/features/Orders/data/models/order_enums.dart';
import 'package:sooq/features/Orders/data/models/order_model.dart';
import 'package:sooq/features/Orders/data/repos/order_repo.dart';
import 'package:sooq/features/Payment/data/models/payment_session.dart';
import 'package:sooq/features/Payment/data/repos/payment_repo.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit({
    required PaymentRepo paymentRepo,
    required OrderRepo orderRepo,
    required OrderModel order,
    this.pollInterval = const Duration(seconds: 2),
    this.maxPolls = 10,
  }) : _paymentRepo = paymentRepo,
       _orderRepo = orderRepo,
       super(PaymentState(order: order));

  final PaymentRepo _paymentRepo;
  final OrderRepo _orderRepo;

  /// How often / how many times the order is re-read while waiting for the webhook.
  final Duration pollInterval;
  final int maxPolls;

  /// Creates a checkout session (also used by "Try again").
  Future<void> start() async {
    emit(state.copyWith(status: PaymentFlowStatus.creating));

    final result = await _paymentRepo.createSession(state.order.id);
    if (isClosed) return;

    result.fold(
      (e) => emit(state.copyWith(status: PaymentFlowStatus.error, errorMessage: e.message)),
      (session) => emit(state.copyWith(status: PaymentFlowStatus.awaiting, session: session)),
    );
  }

  /// The customer finished (or closed) the Paymob page.
  ///
  /// The redirect itself proves nothing: the truth is `orders.payment_status`,
  /// which only the signed webhook can change. So we poll the order.
  Future<void> onPaymentReturn() async {
    if (state.status != PaymentFlowStatus.awaiting) return;
    emit(state.copyWith(status: PaymentFlowStatus.verifying));

    // A previous attempt may have left the order "failed": that old value must
    // not be mistaken for the result of THIS attempt.
    final failedBefore = state.order.paymentStatus == PaymentStatus.failed;
    var stillFailed = false;

    for (var attempt = 0; attempt < maxPolls; attempt++) {
      final result = await _orderRepo.getOrder(state.order.id);
      if (isClosed) return;

      final OrderModel? order = result.fold((_) => null, (o) => o);
      if (order != null) {
        if (order.paymentStatus == PaymentStatus.paid) {
          emit(state.copyWith(status: PaymentFlowStatus.paid, order: order));
          return;
        }
        if (order.paymentStatus == PaymentStatus.failed && !failedBefore) {
          emit(state.copyWith(status: PaymentFlowStatus.failed, order: order));
          return;
        }
        stillFailed = order.paymentStatus == PaymentStatus.failed;
      }

      await Future<void>.delayed(pollInterval);
      if (isClosed) return;
    }

    emit(
      state.copyWith(
        status: (failedBefore && stillFailed) ? PaymentFlowStatus.failed : PaymentFlowStatus.timeout,
      ),
    );
  }
}
