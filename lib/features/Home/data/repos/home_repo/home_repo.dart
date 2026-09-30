import 'package:dartz/dartz.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error.dart';
import 'package:sooq/features/Home/data/models/banner_model.dart';
import 'package:sooq/features/Home/data/models/category_model.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';

abstract interface class HomeRepo {
  Future<Either<SupabaseError, List<CategoryModel>>> getCategories();
  Future<Either<SupabaseError, List<BannerModel>>> getBanners();
  Future<Either<SupabaseError, List<ProductModel>>> getProducts();
}
