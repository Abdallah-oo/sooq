import 'package:sooq/core/constances/product_constants.dart';
import 'package:sooq/core/utils/ld/pref_helper.dart';
import 'package:sooq/features/Home/data/models/products_model.dart';
import 'package:sooq/features/Search/presentation/cubit/search_cubit.dart';

class SearchRepository {

  SearchRepository() {
    // Merge all product lists once at construction
    _allProducts = [
      ...ProductConstants.vegetables,
      ...ProductConstants.fruits,
      ...ProductConstants.dairy,
      ...ProductConstants.proteins,
      ...ProductConstants.laundry,
    ];
  }

  late final List<Product> _allProducts;

  static const int _maxRecent = 8;

  // ── Search + Filter + Sort ──
  List<Product> search({required String query, required SearchFilter filter}) {
    final trimmed = query.trim().toLowerCase();

    // Start with full catalogue or pre-filtered by category
    Iterable<Product> results = filter.category != null
        ? _allProducts.where(
            (p) => p.category.toLowerCase() == filter.category!.toLowerCase(),
          )
        : _allProducts;

    // Query match — name contains query
    if (trimmed.isNotEmpty) {
      results = results.where((p) => p.name.toLowerCase().contains(trimmed));
    }

    // Price range
    if (filter.minPrice != null) {
      results = results.where((p) => p.price >= filter.minPrice!);
    }
    if (filter.maxPrice != null) {
      results = results.where((p) => p.price <= filter.maxPrice!);
    }

    // Minimum rating
    if (filter.minRating != null) {
      results = results.where((p) => p.rate >= filter.minRating!);
    }

    // Sort
    final list = results.toList();
    switch (filter.sortBy) {
      case SortBy.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortBy.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortBy.rating:
        list.sort((a, b) => b.rate.compareTo(a.rate));
        break;
      case SortBy.popularity:
        list.sort((a, b) => b.votes.compareTo(a.votes));
        break;
      case SortBy.relevance:
        // Boost exact name starts-with matches to the top
        list.sort((a, b) {
          final aStarts = a.name.toLowerCase().startsWith(trimmed) ? 0 : 1;
          final bStarts = b.name.toLowerCase().startsWith(trimmed) ? 0 : 1;
          return aStarts.compareTo(bStarts);
        });
        break;
    }

    return list;
  }

  // ── Trending (top-voted across all categories) ──
  List<Product> getTrending({int limit = 8}) {
    final sorted = List<Product>.from(_allProducts)
      ..sort((a, b) => b.votes.compareTo(a.votes));
    return sorted.take(limit).toList();
  }


  Future<void> saveSearch(String query) async {
    if (query.trim().isEmpty) return;
    final current = await PrefHelper.loadRecentSearches() ?? [];

    final updated = [
      query.trim(),
      ...current.where((q) => q != query.trim()),
    ].take(_maxRecent).toList();
    await PrefHelper.saveRecentSearches(updated);
  }

  Future<void> removeRecentSearch(String query) async {
    final current = await PrefHelper.loadRecentSearches() ?? [];
    current.remove(query);
    await PrefHelper.saveRecentSearches(current);
  }
}
