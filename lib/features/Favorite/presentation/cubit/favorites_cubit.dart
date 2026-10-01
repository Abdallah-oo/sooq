import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/core/utils/ld/pref_helper.dart';
import 'package:sooq/features/Favorite/data/repos/favorites_repo.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._repository) : super(const FavoritesState());

  final FavoritesRepository _repository;

  /// The canonical insertion-order list — never sorted.
  final List<ProductModel> _baseOrder = [];

  bool _isToggling = false;

  // ── Load from persistence on app start ──
  Future<void> init() async {
    final saved = await _repository.loadFavorites();
    _baseOrder
      ..clear()
      ..addAll(saved);
    _applySortAndEmit(FavoritesSort.dateAdded, FavoritesStatus.ready);
  }

  // ── Toggle favorite / unfavorite ──
  Future<void> toggleFavorite(ProductModel product) async {
    if (_isToggling) return;
    _isToggling = true;

    try {
      final exists = _baseOrder.any((p) => p.id == product.id);
      if (exists) {
        _baseOrder.removeWhere((p) => p.id == product.id);
      } else {
        _baseOrder.insert(0, product); // newest first in base order
      }

      _applySortAndEmit(state.sort, FavoritesStatus.ready);
      await _repository.saveFavorites(_baseOrder);
    } finally {
      _isToggling = false;
    }
  }

  // ── Change sort ──
  void changeSort(FavoritesSort sort) {
    if (sort == state.sort) return;
    _applySortAndEmit(sort, FavoritesStatus.ready);
  }

  // ── Remove one (called from Dismissible) ──
  Future<void> remove(ProductModel product) async {
    _baseOrder.removeWhere((p) => p.id == product.id);
    _applySortAndEmit(state.sort, FavoritesStatus.ready);
    await _repository.saveFavorites(_baseOrder);
  }

  // ── Clear all ──
  Future<void> clearAll() async {
    _baseOrder.clear();
    emit(state.copyWith(favorites: [], status: FavoritesStatus.ready));
    await _repository.clearFavorites();
  }

  // ── Internal: sort _baseOrder copy and emit ──
  void _applySortAndEmit(FavoritesSort sort, FavoritesStatus status) {
    final sorted = List<ProductModel>.from(_baseOrder);

    switch (sort) {
      case FavoritesSort.dateAdded:
        break; // already in insertion order
      case FavoritesSort.nameAZ:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case FavoritesSort.nameZA:
        sorted.sort((a, b) => b.name.compareTo(a.name));
        break;
      case FavoritesSort.priceLow:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case FavoritesSort.priceHigh:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case FavoritesSort.rating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    emit(state.copyWith(favorites: sorted, sort: sort, status: status));
  }
}
