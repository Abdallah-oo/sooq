import 'package:sooq/core/services/hive/hive_services.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';

class ProductsLocalDataSource {
  List<ProductModel> readFirstPage(String categoryId) => HiveService.getHomeProducts(categoryId);

  Future<void> saveFirstPage(String categoryId, List<ProductModel> products) =>
      HiveService.saveHomeProducts(categoryId, products);
}
