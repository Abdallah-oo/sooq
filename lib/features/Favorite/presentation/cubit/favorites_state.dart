part of 'favorites_cubit.dart';

enum FavoritesStatus { loading, ready }

enum FavoritesSort { dateAdded, nameAZ, nameZA, priceLow, priceHigh, rating }

class FavoritesState {
  final FavoritesStatus status;
  final List<Product> favorites;
  final FavoritesSort sort;

  const FavoritesState({
    this.status = FavoritesStatus.loading,
    this.favorites = const [],
    this.sort = FavoritesSort.dateAdded,
  });

  bool isFavorite(Product product) =>
      favorites.any((p) => p.name == product.name);

  int get count => favorites.length;

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<Product>? favorites,
    FavoritesSort? sort,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      sort: sort ?? this.sort,
    );
  }
}
