part of 'search_cubit.dart';

//sort by state enum
enum SearchSortBy  { relevance, priceLow, priceHigh, rating, popularity }

//search filters
class SearchFilter {
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final String? category;
  final SearchSortBy  sortBy;

  const SearchFilter({
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.category,
    this.sortBy = SearchSortBy.relevance,
  });

  SearchFilter copyWith({
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? category,
    SearchSortBy? sortBy,
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
      sortBy != SearchSortBy.relevance;

  int get activeFilterCount {
    int count = 0;
    if (minPrice != null || maxPrice != null) count++;
    if (minRating != null) count++;
    if (category != null) count++;
    if (sortBy != SearchSortBy.relevance) count++;
    return count;
  }
}

// Screen states
enum SearchStatus { idle, loading, results, empty, error }

// ── Main state ──
class SearchState {
  final SearchStatus status;
  final String query;
  final List<ProductModel> results;
  final List<String> recentSearches;
  final List<String> trending;
  final SearchFilter filter;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.idle,
    this.query = '',
    this.results = const [],
    this.recentSearches = const [],
    this.trending = const [],
    this.filter = const SearchFilter(),
    this.isLoadingMore = false,
    this.hasMore = false,
    this.errorMessage,
  });

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<ProductModel>? results,
    List<String>? recentSearches,
    List<String>? trending,
    SearchFilter? filter,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      trending: trending ?? this.trending,
      filter: filter ?? this.filter,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
