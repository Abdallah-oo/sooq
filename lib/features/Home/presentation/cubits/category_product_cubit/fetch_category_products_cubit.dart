// category_products_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';
import 'package:sooq/features/Home/data/repos/category_product_repo/category_product_repo.dart';

part 'fetch_category_products_state.dart';

class FetchCategoryProductsCubit extends Cubit<FetchCategoryProductsState> {
  final CategoryProductsRepo repo;
  final String categoryId;

  final int pageSize;
  final List<ProductModel> _products = [];
  int _nextPageKey = 0;
  bool _hasReachedMax = false;
  bool _isFetching = false;

  FetchCategoryProductsCubit({required this.repo, required this.categoryId,this.pageSize = 7})
    : super(FetchCategoryProductsInitial());



  Future<void> fetchCategoryProducts() async {
    _products.clear();
    _nextPageKey = 0;
    _hasReachedMax = false;
    final cached = repo.getCachedFirstPage(categoryId);
    if (cached.isNotEmpty) {
      _products.addAll(cached);
      emit(
        FetchCategoryProductsSuccess(products: List.unmodifiable(_products), hasReachedMax: false),
      );
    } else {
      emit(FetchCategoryProductsLoading());
    }

    // 2. دايمًا كلم السيرفر كمان، وحدّث بالنسخة الطازة (حتى لو كان فيه كاش)
    _products.clear();
    await _fetchPage();
  }

  Future<void> _fetchPage() async {
    _isFetching = true;
    final result = await repo.getProductsByCategory(categoryId: categoryId, page: _nextPageKey,pageSize:pageSize);
    _isFetching = false;

    result.fold(
      (error) {
        if (_products.isEmpty) {
          emit(FetchCategoryProductsFailure(errorMessage: error.message));
        } else {
          emit(
            FetchCategoryProductsLoadMoreFailure(
              products: List.unmodifiable(_products),
              errorMessage: error.message,
            ),
          );
        }
      },
      (newproducts) {
        if (newproducts.length < pageSize) {
          _hasReachedMax = true;
        }
        _products.addAll(newproducts);
        _nextPageKey++;
        emit(
          FetchCategoryProductsSuccess(
            products: List.unmodifiable(_products),
            hasReachedMax: _hasReachedMax,
          ),
        );
      },
    );
  }

  /// جلب الصفحة اللي بعد كده
  Future<void> fetchNextPage() async {
    if (_isFetching || _hasReachedMax) return;
    emit(FetchCategoryProductsLoadingMore(products: List.unmodifiable(_products)));
    await _fetchPage();
  }
}
