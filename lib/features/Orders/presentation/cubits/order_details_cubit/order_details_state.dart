part of 'order_details_cubit.dart';

class OrderDetailsState {
  const OrderDetailsState({
    this.isLoading = false,
    this.isCancelling = false,
    this.order,
    this.loadError,
    this.actionError,
  });

  final bool isLoading;
  final bool isCancelling;
  final OrderModel? order;

  /// Full-screen error (order could not be loaded).
  final String? loadError;

  /// Transient error shown as a snackbar.
  final String? actionError;

  /// Errors reset when not passed (same convention as `HomeState`).
  OrderDetailsState copyWith({
    bool? isLoading,
    bool? isCancelling,
    OrderModel? order,
    String? loadError,
    String? actionError,
  }) {
    return OrderDetailsState(
      isLoading: isLoading ?? this.isLoading,
      isCancelling: isCancelling ?? this.isCancelling,
      order: order ?? this.order,
      loadError: loadError,
      actionError: actionError,
    );
  }
}
