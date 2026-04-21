import 'package:sooq/core/constances/product_constants.dart';
import 'package:sooq/core/utils/iterable_helper.dart';
import 'package:sooq/core/utils/ld/pref_helper.dart';
import 'package:sooq/features/Home/data/models/products_model.dart';

class FavoritesRepository {


  /// Load persisted favorites, reconstructing full Product objects.
  Future<List<Product>> loadFavorites() async {
    final names = await PrefHelper.loadFavorites() ?? [];
    // Preserve insertion order by mapping names back to Products
    return names
        .map(
          (name) =>
              ProductConstants.all.firstWhereOrNull((p) => p.name == name),
        )
        .whereType<Product>()
        .toList();
  }

  /// Persist the current favorites list (preserves order).
  Future<void> saveFavorites(List<Product> favorites) async {
    await PrefHelper.saveFavorites(favorites.map((p) => p.name).toList());
  }
}
