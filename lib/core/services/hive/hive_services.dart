import 'package:hive_ce/hive.dart';
import 'package:sooq/features/Cart/data/models/cart_item.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';

class HiveService {
  static const String productsBoxName = 'HomeProducts';
  static const String cartBoxName = 'Cart';
  static const String _itemsKey = 'items';

  static Box get _productBox => Hive.box(productsBoxName);
  static Box get _cartBox => Hive.box(productsBoxName);
  // product local storage fun
  static Future<void> saveHomeProducts(String categoryId, List<ProductModel> products) async {
    await _productBox.put(categoryId, products);
  }

  static List<ProductModel> getHomeProducts(String categoryId) {
    final raw = _productBox.get(categoryId);
    if (raw == null) return [];
    return (raw as List).cast<ProductModel>();
  }

  // cart local storage fun
  static Future<void> saveCartProducts(List<CartItem> items) async {
    await _cartBox.put(_itemsKey, items);
  }

  static List<CartItem> getCartProducts() {
    final raw = _productBox.get(_itemsKey);
    if (raw == null) return [];
    return (raw as List).cast<CartItem>();
  }
}
