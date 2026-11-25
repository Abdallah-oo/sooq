part of 'orders_cubit.dart';

class OrdersState {
  const OrdersState({
    this.isLoading = false,
    this.orders = const [],
    this.loadError,
    this.actionError,
  });

  final bool isLoading;
  final List<OrderModel> orders;

  /// Full-screen error when the list could not be loaded.
  final String? loadError;

  /// Transient error shown as a snackbar; the list stays visible.
  final String? actionError;

  /// Errors reset when not passed (same convention as `HomeState`).
  OrdersState copyWith({
    bool? isLoading,
    List<OrderModel>? orders,
    String? loadError,
    String? actionError,
  }) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      loadError: loadError,
      actionError: actionError,
    );
  }
}
