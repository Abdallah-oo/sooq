import 'package:dartz/dartz.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error.dart';
import 'package:sooq/core/services/supabase/errors/supabase_error_handler.dart';
import 'package:sooq/features/Home/data/models/banner_model.dart';
import 'package:sooq/features/Home/data/models/category_model.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';
import 'package:sooq/features/Home/data/repos/home_repo/home_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRepoImpl implements HomeRepo {
  final SupabaseClient client;
  HomeRepoImpl(this.client);
  @override
  Future<Either<SupabaseError, List<CategoryModel>>> getCategories() async {
    try {
      final response = await client.from('categories').select().order('name');

      final categories = (response as List).map((row) => CategoryModel.fromJson(row)).toList();

      return Right(categories);
    } catch (e) {
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }

  @override
  Future<Either<SupabaseError, List<BannerModel>>> getBanners() async {
    try {
      final response = await client
          .from('banners')
          .select()
          .eq('is_active', true)
          .order('sort_order');

      final banners = (response as List).map((row) => BannerModel.fromJson(row)).toList();

      return Right(banners);
    } catch (e) {
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }

  @override
  Future<Either<SupabaseError, List<ProductModel>>> getProducts() async {
    try {
      final response = await client.from('products').select().order('created_at').limit(7);

      final products = (response as List).map((row) => ProductModel.fromJson(row)).toList();

      return Right(products);
    } catch (e) {
      return Left(SupabaseErrorHandler.handleSupabaseError(e));
    }
  }
}
