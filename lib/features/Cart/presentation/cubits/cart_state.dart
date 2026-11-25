part of 'cart_cubit.dart';

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Display estimate only: the real total (delivery, promo) comes from the server at checkout.
  double get totalPrice =>
      items.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  CartState copyWith({List<CartItem>? items}) =>
      CartState(items: items ?? this.items);
}
