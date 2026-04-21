part of 'cart_cubit.dart';
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);
}

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      items.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  CartState copyWith({List<CartItem>? items}) =>
      CartState(items: items ?? this.items);
}
