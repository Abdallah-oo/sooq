import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/features/Orders/data/models/order_model.dart';
import 'package:sooq/features/Orders/data/repos/order_repo.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repo) : super(const OrdersState(isLoading: true));

  final OrderRepo _repo;

  /// [silent] keeps the current list visible (pull-to-refresh / coming back
  /// from the details screen) and reports failures as a transient `actionError`.
  Future<void> fetchOrders({bool silent = false}) async {
    if (!silent) emit(state.copyWith(isLoading: true));

    final result = await _repo.getOrders();
    result.fold(
      (e) => emit(
        silent
            ? state.copyWith(actionError: e.message)
            : state.copyWith(isLoading: false, loadError: e.message),
      ),
      (orders) => emit(state.copyWith(isLoading: false, orders: orders)),
    );
  }
}
