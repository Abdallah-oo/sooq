import 'package:hive_ce/hive.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';

extension HiveRegistrar on HiveInterface {
  void registerAdapters() {
    registerAdapter(ProductModelAdapter());
  }
}
