import 'package:dartz/dartz.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error_handler.dart';
import 'package:sooq/features/Home/data/local/products_local_data_source.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';
import 'package:sooq/features/Home/data/repos/category_product_repo/category_product_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryProductRepoImpl implements CategoryProductsRepo {
  final SupabaseClient client;
  final ProductsLocalDataSource _local;
  const CategoryProductRepoImpl(this.client, this._local);
  @override
  Future<Either<SupabaseError, List<ProductModel>>> getProductsByCategory({
    required String categoryId,
    required int page,
    required int pageSize ,
  }) async {
    try {
      final start = page * pageSize;
      final end = start + pageSize - 1;

      final response = await client
          .from('products')
          .select('*, categories(name)')
          .eq('category_id', categoryId)
          .order('created_at')
          .range(start, end);

      final products = (response as List).map((row) => ProductModel.fromJson(row)).toList();
      if (page == 0) await _local.saveFirstPage(categoryId, products);
      return Right(products);
    } catch (e) {
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }
  @override
  List<ProductModel> getCachedFirstPage(String categoryId) => _local.readFirstPage(categoryId);
}
