import 'package:hive_ce/hive.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';

class HiveService {
  static const String productsBoxName = 'HomeProducts';

  static Box get _box => Hive.box(productsBoxName);

  static Future<void> saveHomeProducts(String categoryId, List<ProductModel> products) async {
    await _box.put(categoryId, products);
  }

  static List<ProductModel> getHomeProducts(String categoryId) {
    final raw = _box.get(categoryId);
    if (raw == null) return [];
    return (raw as List).cast<ProductModel>();
  }
}
