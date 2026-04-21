part of 'search_cubit.dart';

//sort by state enum
enum SortBy { relevance, priceLow, priceHigh, rating, popularity }

//search filters
class SearchFilter {
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final String? category;
  final SortBy sortBy;

  const SearchFilter({
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.category,
    this.sortBy = SortBy.relevance,
  });

  SearchFilter copyWith({
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? category,
    SortBy? sortBy,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearMinRating = false,
    bool clearCategory = false,
  }) {
    return SearchFilter(
      minPrice: clearMinPrice ? null : minPrice ?? this.minPrice,
      maxPrice: clearMaxPrice ? null : maxPrice ?? this.maxPrice,
      minRating: clearMinRating ? null : minRating ?? this.minRating,
      category: clearCategory ? null : category ?? this.category,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters =>
      minPrice != null ||
      maxPrice != null ||
      minRating != null ||
      category != null ||
      sortBy != SortBy.relevance;

  int get activeFilterCount {
    int count = 0;
    if (minPrice != null || maxPrice != null) count++;
    if (minRating != null) count++;
    if (category != null) count++;
    if (sortBy != SortBy.relevance) count++;
    return count;
  }
}

// Screen states
enum SearchStatus { idle, loading, results, empty, error }

// ── Main state ──
class SearchState {
  final SearchStatus status;
  final String query;
  final List<Product> results;
  final List<String> recentSearches;
  final SearchFilter filter;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.idle,
    this.query = '',
    this.results = const [],
    this.recentSearches = const [],
    this.filter = const SearchFilter(),
    this.errorMessage,
  });

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Product>? results,
    List<String>? recentSearches,
    SearchFilter? filter,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
