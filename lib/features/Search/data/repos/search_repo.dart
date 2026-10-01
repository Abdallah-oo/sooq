
import 'package:dartz/dartz.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error_handler.dart';
import 'package:sooq/core/utils/ld/pref_helper.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';
import 'package:sooq/features/Search/presentation/cubit/search_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchRepository {
  final SupabaseClient _client;
  static const int pageSize = 20;
  static const int _maxRecent = 8;
  const SearchRepository(this._client);

  // ── Search + Filter + Sort (كله على السيرفر) ──
  Future<Either<SupabaseError, List<ProductModel>>> search({
    required String query,
    required SearchFilter filter,
    int page = 0,
  }) async {
    try {
      final term = _escapeLike(query.trim());

      // inner join لما نفلتر بالكاتيجوري عشان نستبعد المنتجات التانية
      final join = filter.category != null ? 'categories!inner(name)' : 'categories(name)';

      var builder = _client.from('products').select('*, $join');

      if (term.isNotEmpty) builder = builder.ilike('name', '%$term%');
      if (filter.category != null) {
        builder = builder.ilike('categories.name', filter.category!);
      }
      if (filter.minPrice != null) builder = builder.gte('price', filter.minPrice!);
      if (filter.maxPrice != null) builder = builder.lte('price', filter.maxPrice!);
      if (filter.minRating != null) builder = builder.gte('rating', filter.minRating!);

      final (column, ascending) = switch (filter.sortBy) {
     SearchSortBy.priceLow => ('price', true),
        SearchSortBy.priceHigh => ('price', false),
        SearchSortBy.rating => ('rating', false),
        SearchSortBy.popularity => ('votes', false),
        SearchSortBy.relevance => ('name', true),
      };

      final from = page * pageSize;
      final response = await builder
          .order(column, ascending: ascending)
          .order('id') // tie-breaker: من غيره الصفحات ممكن تكرر أو تفوّت منتجات
          .range(from, from + pageSize - 1);

      var products = (response as List).map((row) => ProductModel.fromJson(row)).toList();

      // Relevance: اللي بيبدأ بالكلمة يطلع الأول (داخل الصفحة الحالية)
      if (filter.sortBy == SearchSortBy.relevance && term.isNotEmpty) {
        final q = query.trim().toLowerCase();
        products = [
          ...products.where((p) => p.name.toLowerCase().startsWith(q)),
          ...products.where((p) => !p.name.toLowerCase().startsWith(q)),
        ];
      }

      return Right(products);
    } catch (e) {
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }

  // ── Trending: أسماء بس (خفيف) ──
  Future<Either<SupabaseError, List<String>>> getTrending({int limit = 8}) async {
    try {
      final response = await _client
          .from('products')
          .select('name')
          .order('votes', ascending: false)
          .order('id')
          .limit(limit);

      return Right((response as List).map((r) => r['name'] as String).toList());
    } catch (e) {
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }

  // ── Recent searches (زي ما هي) ──
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

  // لو اليوزر كتب % أو _ متتعاملش كـ wildcard
  String _escapeLike(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
}
