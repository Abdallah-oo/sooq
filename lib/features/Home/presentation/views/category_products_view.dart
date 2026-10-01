import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/core/routing/app_router.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/utils/di/get_it.dart';
import 'package:sooq/features/Home/data/repos/category_product_repo/category_product_repo.dart';
import 'package:sooq/features/Home/presentation/cubits/category_product_cubit/fetch_category_products_cubit.dart';
import 'package:sooq/features/Home/presentation/views/widgets/category_products_grid.dart';

class CategoryProductsView extends StatelessWidget {
  const CategoryProductsView({super.key, required this.params});
  final CategoryProductsViewParameters params;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => FetchCategoryProductsCubit(
            repo: getIt<CategoryProductsRepo>(),
            categoryId: params.category.id,
            pageSize: 20, 
          )..fetchCategoryProducts(),
        ),
        BlocProvider.value(value: params.favoritesCubit),
        BlocProvider.value(value: params.cartCubit),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: CustomText(text: params.category.name, style: AppTextStyles.titleLarge),
        ),
        body: const CategoryProductsGrid(),
      ),
    );
  }
}
