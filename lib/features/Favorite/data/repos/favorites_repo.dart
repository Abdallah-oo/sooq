import 'dart:convert';
import 'package:sooq/core/utils/ld/pref_helper.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';

abstract class FavoritesRepository {
  Future<List<ProductModel>> loadFavorites();
  Future<void> saveFavorites(List<ProductModel> favorites);
  Future<void> clearFavorites();
}

class FavoritesRepositoryImpl implements FavoritesRepository {
  @override
  Future<List<ProductModel>> loadFavorites() async {
    final raw = await PrefHelper.loadFavorites() ?? const <String>[];
    final result = <ProductModel>[];
    for (final item in raw) {
      try {
        result.add(ProductModel.fromJson(jsonDecode(item) as Map<String, dynamic>));
      } catch (_) {}
    }
    return result;
  }

  @override
  Future<void> saveFavorites(List<ProductModel> favorites) =>
      PrefHelper.saveFavorites(favorites.map((p) => jsonEncode(p.toJson())).toList());

  @override
  Future<void> clearFavorites() => PrefHelper.clearFavorites();
}
