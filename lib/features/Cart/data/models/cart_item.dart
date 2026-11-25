import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:sooq/core/services/hive/hive_types_ids.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';
part 'cart_item.g.dart';


@HiveType(typeId: HiveTypeIds.cart)
class CartItem {
  const CartItem({required this.product, required this.quantity});
  @HiveField(0)
  final ProductModel product;
  @HiveField(1)
  final int quantity;

  double get lineTotal => product.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  Map<String, dynamic> toJson() => {'product': product.toJson(), 'quantity': quantity};

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(Map<String, dynamic>.from(json['product'] as Map)),
      quantity: json['quantity'] as int,
    );
  }
}
