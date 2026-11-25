import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/core/services/hive/hive_services.dart';
import 'package:sooq/features/Cart/data/models/cart_item.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';

// Existing code keeps importing CartItem through this file.
export 'package:sooq/features/Cart/data/models/cart_item.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  /// The cart is restored synchronously from [storage], so it is ready on the first frame.
  CartCubit() : super(CartState(items: HiveService.getCartProducts()));

  /// Every change (add / remove / clear) is persisted automatically.
  @override
  void onChange(Change<CartState> change) {
    super.onChange(change);
    unawaited(HiveService.saveCartProducts(change.nextState.items));
  }

  void addItem(ProductModel product) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((e) => e.product.id == product.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }
    emit(state.copyWith(items: items));
  }

  int quantityOf(ProductModel product) {
    final index = state.items.indexWhere((e) => e.product.id == product.id);
    return index >= 0 ? state.items[index].quantity : 0;
  }

  void removeItem(ProductModel product) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((e) => e.product.id == product.id);
    if (index < 0) return;

    if (items[index].quantity > 1) {
      items[index] = items[index].copyWith(quantity: items[index].quantity - 1);
    } else {
      items.removeAt(index);
    }
    emit(state.copyWith(items: items));
  }

  void removeAllOf(ProductModel product) {
    final items = List<CartItem>.from(state.items)..removeWhere((e) => e.product.id == product.id);
    emit(state.copyWith(items: items));
  }

  void clearCart() => emit(const CartState());
}
