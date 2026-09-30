import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sooq/core/extensions/responsive.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/utils/di/get_it.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';
import 'package:sooq/features/Home/data/repos/category_product_repo/category_product_repo.dart';
import 'package:sooq/features/Home/presentation/cubits/category_cubit/category_cubit.dart';
import 'package:sooq/features/Home/presentation/cubits/category_product_cubit/fetch_category_products_cubit.dart';
import 'package:sooq/features/Home/presentation/cubits/home_cubit/home_cubit.dart';
import 'package:sooq/features/Home/presentation/views/widgets/product_card.dart';

class ProductsSection extends StatelessWidget {
  const ProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = context.select((HomeCubit c) => c.state.categories);
    final index = context.select((CategoryCubit c) => c.state.selectedIndex);
    if (categories.isEmpty) return const SizedBox.shrink();

    final category = categories[index];

    return BlocProvider(
      key: ValueKey(category.id), // تغيير الكاتيجوري = cubit جديد، والقديم بيتقفل
      create: (_) =>
          FetchCategoryProductsCubit(repo: getIt<CategoryProductsRepo>(), categoryId: category.id)
            ..fetchCategoryProducts(),
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomText(text: category.name, style: AppTextStyles.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () {}, // هنوصلها بشاشة See All بعدين
                  child: CustomText(
                    text: 'See all',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                  ),
                ),
                const Gap(5),
              ],
            ),
            const Gap(12),
            const _ProductsList(),
          ],
        ),
      ),
    );
  }
}

class _ProductsList extends StatelessWidget {
  const _ProductsList();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchCategoryProductsCubit, FetchCategoryProductsState>(
      builder: (context, state) {
        final cubit = context.read<FetchCategoryProductsCubit>();

        if (state is FetchCategoryProductsSuccess) {
          return _BuildProductsList(products: state.products);
        } else if (state is FetchCategoryProductsLoadingMore) {
          return _BuildProductsList(products: state.products);
        } else if (state is FetchCategoryProductsLoadMoreFailure) {
          return _BuildProductsList(products: state.products);
        } else if (state is FetchCategoryProductsFailure) {
          return Center(
            child: Column(
              children: [
                Text(state.errorMessage, style: const TextStyle(fontSize: 14)),
                const Gap(20),
                _FetchProductsRetryButton(cubit: cubit),
              ],
            ),
          );
        } else {
          return SizedBox(
            height: context.screenHeight * 0.28,
            child: const _LoadingHomeBooksState(),
          );
        }
      },
    );
  }
}

class _BuildProductsList extends StatefulWidget {
  const _BuildProductsList({required this.products});
  final List<ProductModel> products;
  @override
  State<_BuildProductsList> createState() => _BuildProductsListState();
}

class _BuildProductsListState extends State<_BuildProductsList> {
  late final ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<FetchCategoryProductsCubit>().state;
    if (state is! FetchCategoryProductsLoadingMore &&
        !(state is FetchCategoryProductsSuccess && state.hasReachedMax) &&
        _scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (_scrollController.position.pixels >= maxScroll - 400) {
        context.read<FetchCategoryProductsCubit>().fetchNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.products.length + (widget.products.isEmpty ? 0 : 1);

    return SizedBox(
      height: context.screenHeight * 0.28,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index >= widget.products.length) {
            return _buildTrailingItem(context.read<FetchCategoryProductsCubit>());
          }
          return ProductCard(product: widget.products[index]);
        },
      ),
    );
  }

  Widget _buildTrailingItem(FetchCategoryProductsCubit cubit) {
    final state = cubit.state;
    if (state is FetchCategoryProductsLoadingMore) {
      return const Padding(
        padding: EdgeInsets.only(right: 10),
        child: SizedBox(
          width: 150,
          child: Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ),
        ),
      );
    } else if (state is FetchCategoryProductsLoadMoreFailure) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: SizedBox(
          width: 150,
          child: InkWell(
            onTap: cubit.fetchNextPage,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: Colors.redAccent),
                  SizedBox(height: 4),
                  Text('Retry', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (state is FetchCategoryProductsSuccess && state.hasReachedMax) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: SizedBox(
          width: 150,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.grey.shade500),
                const SizedBox(height: 4),
                const CustomText(text: 'No more products', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ),
      );
    } else {
      return const SizedBox(width: 10);
    }
  }
}

class _FetchProductsRetryButton extends StatelessWidget {
  const _FetchProductsRetryButton({required this.cubit});

  final FetchCategoryProductsCubit cubit;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => cubit.fetchCategoryProducts(),
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10)),
        backgroundColor: WidgetStatePropertyAll(AppColors.primary),
      ),

      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('Retry', style: TextStyle(color: Colors.white, fontSize: 16))],
      ),
    );
  }
}

class _LoadingHomeBooksState extends StatelessWidget {
  const _LoadingHomeBooksState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) => const Skeletonizer(
        enabled: true,
        child: ProductCard(
          product: ProductModel(
            id: '',
            name: 'name',
            imageUrl: 'imageUrl',
            price: 1,
            rating: 1,
            votes: 1,
            categoryId: '',
          ),
        ),
      ),
    );
  }
}
