part of 'favorites_cubit.dart';

enum FavoritesStatus { loading, ready }

enum FavoritesSort { dateAdded, nameAZ, nameZA, priceLow, priceHigh, rating }

class FavoritesState {
  final FavoritesStatus status;
  final List<ProductModel> favorites;
  final FavoritesSort sort;

  const FavoritesState({
    this.status = FavoritesStatus.loading,
    this.favorites = const [],
    this.sort = FavoritesSort.dateAdded,
  });


  bool isFavorite(ProductModel product) => favorites.any((p) => p.id == product.id);

  int get count => favorites.length;

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<ProductModel>? favorites,
    FavoritesSort? sort,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      sort: sort ?? this.sort,
    );
  }
}
