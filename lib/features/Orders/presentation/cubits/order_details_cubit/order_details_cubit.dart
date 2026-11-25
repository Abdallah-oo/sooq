import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/features/Orders/data/models/order_model.dart';
import 'package:sooq/features/Orders/data/repos/order_repo.dart';

part 'order_details_state.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit(this._repo, this._orderId) : super(const OrderDetailsState(isLoading: true));

  final OrderRepo _repo;
  final String _orderId;

  Future<void> fetchOrder({bool silent = false}) async {
    if (!silent) emit(state.copyWith(isLoading: true));

    final result = await _repo.getOrder(_orderId);
    result.fold(
      (e) => emit(
        silent
            ? state.copyWith(actionError: e.message)
            : state.copyWith(isLoading: false, loadError: e.message),
      ),
      (order) => emit(state.copyWith(isLoading: false, order: order)),
    );
  }

  Future<void> cancelOrder() async {
    if (state.isCancelling || state.order == null) return;
    emit(state.copyWith(isCancelling: true));

    final result = await _repo.cancelOrder(_orderId);
    await result.fold(
      (e) async {
        emit(state.copyWith(isCancelling: false, actionError: e.message));
        // The status may have changed meanwhile (e.g. confirmed by the store).
        await fetchOrder(silent: true);
      },
      (order) async => emit(state.copyWith(isCancelling: false, order: order)),
    );
  }
}
