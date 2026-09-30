import 'package:dartz/dartz.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';

abstract interface class CategoryProductsRepo {
  Future<Either<SupabaseError, List<ProductModel>>> getProductsByCategory({
    required String categoryId,
    required int page,
    required int pageSize ,
  });

  List<ProductModel> getCachedFirstPage(String categoryId );
}
