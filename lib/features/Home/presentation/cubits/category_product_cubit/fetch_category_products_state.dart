// category_products_state.dart
part of 'fetch_category_products_cubit.dart';



@immutable
sealed class FetchCategoryProductsState {}

final class FetchCategoryProductsInitial extends FetchCategoryProductsState {}

final class FetchCategoryProductsLoading extends FetchCategoryProductsState {}

final class FetchCategoryProductsSuccess extends FetchCategoryProductsState {
  final List<ProductModel> products;
  final bool hasReachedMax;
  FetchCategoryProductsSuccess({required this.products, required this.hasReachedMax});
}

final class FetchCategoryProductsLoadingMore extends FetchCategoryProductsState {
  final List<ProductModel> products;
  FetchCategoryProductsLoadingMore({required this.products});
}

final class FetchCategoryProductsLoadMoreFailure extends FetchCategoryProductsState {
  final List<ProductModel> products;
  final String errorMessage;
  FetchCategoryProductsLoadMoreFailure({required this.products, required this.errorMessage});
}

final class FetchCategoryProductsFailure extends FetchCategoryProductsState {
  final String errorMessage;
  FetchCategoryProductsFailure({required this.errorMessage});
}
