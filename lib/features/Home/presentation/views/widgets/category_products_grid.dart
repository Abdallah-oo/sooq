import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';
import 'package:sooq/features/Home/presentation/cubits/category_product_cubit/fetch_category_products_cubit.dart';
import 'package:sooq/features/Home/presentation/views/widgets/product_card.dart';

class CategoryProductsGrid extends StatefulWidget {
  const CategoryProductsGrid({super.key});

  @override
  State<CategoryProductsGrid> createState() => _CategoryProductsGridState();
}

class _CategoryProductsGridState extends State<CategoryProductsGrid> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<FetchCategoryProductsCubit>().state;
    final notLoadingMore = state is! FetchCategoryProductsLoadingMore;
    final notMaxed = !(state is FetchCategoryProductsSuccess && state.hasReachedMax);

    if (notLoadingMore && notMaxed && _controller.hasClients) {
      final max = _controller.position.maxScrollExtent;
      if (_controller.position.pixels >= max - 300) {
        context.read<FetchCategoryProductsCubit>().fetchNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchCategoryProductsCubit, FetchCategoryProductsState>(
      builder: (context, state) {
        if (state is FetchCategoryProductsFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<FetchCategoryProductsCubit>().fetchCategoryProducts(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is FetchCategoryProductsInitial || state is FetchCategoryProductsLoading) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemCount: 6,
            itemBuilder: (_, __) => const Skeletonizer(
              enabled: true,
              child: ProductCard(
                product: ProductModel(
                  id: '',
                  name: 'name',
                  imageUrl: '',
                  price: 1,
                  rating: 1,
                  votes: 1,
                  categoryId: '',
                ),
              ),
            ),
          );
        }

        final products = switch (state) {
          FetchCategoryProductsSuccess(:final products) => products,
          FetchCategoryProductsLoadingMore(:final products) => products,
          FetchCategoryProductsLoadMoreFailure(:final products) => products,
          _ => const <ProductModel>[],
        };

        final isLoadingMore = state is FetchCategoryProductsLoadingMore;
        final loadMoreFailed = state is FetchCategoryProductsLoadMoreFailure;

        return GridView.builder(
          controller: _controller,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemCount: products.length + (isLoadingMore || loadMoreFailed ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= products.length) {
              if (loadMoreFailed) {
                return Center(
                  child: TextButton(
                    onPressed: () => context.read<FetchCategoryProductsCubit>().fetchNextPage(),
                    child: const Text('Retry'),
                  ),
                );
              }
              return const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return ProductCard(product: products[index]);
          },
        );
      },
    );
  }
}
