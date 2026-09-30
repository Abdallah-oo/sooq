import 'package:flutter_bloc/flutter_bloc.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit() : super(const CategoryState());

  void selectCategory(int index) {
    if (state.selectedIndex == index) return;
    emit(CategoryState(selectedIndex: index));
  }
}
