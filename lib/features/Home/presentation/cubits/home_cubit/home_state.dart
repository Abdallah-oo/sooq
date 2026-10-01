part of 'home_cubit.dart';

class HomeState {
  final bool isLoading;
  final List<CategoryModel> categories;
  final List<BannerModel> banners;
  final String? errorMessage;

  const HomeState({
    this.isLoading = false,
    this.categories = const [],
    this.banners = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    bool? isLoading,
    List<CategoryModel>? categories,
    List<BannerModel>? banners,
    String? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      banners: banners ?? this.banners,
      errorMessage: errorMessage,
    );
  }
}
