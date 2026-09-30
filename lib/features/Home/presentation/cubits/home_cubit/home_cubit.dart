import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/features/Home/data/models/banner_model.dart';
import 'package:sooq/features/Home/data/models/category_model.dart';
import 'package:sooq/features/Home/data/repos/home_repo/home_repo.dart';


part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo homeRepo;

  HomeCubit(this.homeRepo) : super(const HomeState());

  Future<void> fetchHomeData() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final (categories, banners) = await (homeRepo.getCategories(), homeRepo.getBanners()).wait;

    categories.fold(
      (e) => emit(state.copyWith(isLoading: false, errorMessage: e.message)),
      (cats) => banners.fold(
        (e) => emit(state.copyWith(isLoading: false, errorMessage: e.message)),
        (bans) => emit(state.copyWith(isLoading: false, categories: cats, banners: bans)),
      ),
    );
  }
}
