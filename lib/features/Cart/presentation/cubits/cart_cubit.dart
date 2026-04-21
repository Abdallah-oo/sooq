import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/features/Home/data/models/products_model.dart';
part   'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());
//add item
  void addItem(Product product) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((e) => e.product.name == product.name);

    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }
    emit(state.copyWith(items: items));
  }


//remove item
  void removeItem(Product product) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((e) => e.product.name == product.name);
    if (index < 0) return;

    if (items[index].quantity > 1) {
      items[index] = items[index].copyWith(quantity: items[index].quantity - 1);
    } else {
      items.removeAt(index);
    }
    emit(state.copyWith(items: items));
  }
  //remove all items

  void removeAllOf(Product product) {
    final items = List<CartItem>.from(state.items)
      ..removeWhere((e) => e.product.name == product.name);
    emit(state.copyWith(items: items));
  }

  void clearCart() => emit(const CartState());

  int quantityOf(Product product) {
    final index = state.items.indexWhere((e) => e.product.name == product.name);
    return index >= 0 ? state.items[index].quantity : 0;
  }
}
