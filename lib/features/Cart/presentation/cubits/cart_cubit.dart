import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';
part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());
  //add item
  void addItem(ProductModel product) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((e) => e.product.id == e.product.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }
    emit(state.copyWith(items: items));
  }

  int quantityOf(ProductModel product) {
    final index = state.items.indexWhere((e) => e.product.id == e.product.id);
    return index >= 0 ? state.items[index].quantity : 0;
  }

  void removeItem(ProductModel product) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((e) => e.product.id == e.product.id);
    if (index < 0) return;

    if (items[index].quantity > 1) {
      items[index] = items[index].copyWith(quantity: items[index].quantity - 1);
    } else {
      items.removeAt(index);
    }
    emit(state.copyWith(items: items));
  }

  void removeAllOf(ProductModel product) {
    final items = List<CartItem>.from(state.items)
      ..removeWhere((e) => e.product.id == e.product.id);
    emit(state.copyWith(items: items));
  }

  void clearCart() => emit(const CartState());
}
