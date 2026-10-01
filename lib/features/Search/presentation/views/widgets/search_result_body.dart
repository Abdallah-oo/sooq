import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/widgets/app_network_image.dart';
import 'package:sooq/features/Cart/presentation/cubits/cart_cubit.dart';
import 'package:sooq/features/Favorite/presentation/cubit/favorites_cubit.dart';
import 'package:sooq/features/Favorite/presentation/views/widgets/favorite_btn.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';
import 'package:sooq/features/Search/presentation/cubit/search_cubit.dart';

class SearchResultsBody extends StatelessWidget {
  const SearchResultsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      buildWhen: (p, c) =>
          p.results != c.results || p.isLoadingMore != c.isLoadingMore || p.hasMore != c.hasMore,
      builder: (context, state) {
        final count = '${state.results.length}${state.hasMore ? '+' : ''}';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.bodyMedium,
                  children: [
                    TextSpan(
                      text: '$count ',
                      style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary),
                    ),
                    TextSpan(
                      text:
                          'result${state.results.length == 1 && !state.hasMore ? '' : 's'} '
                          'for "${state.query}"',
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.extentAfter < 300) {
                    context.read<SearchCubit>().loadMore();
                  }
                  return false;
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: state.results.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const Gap(12),
                  itemBuilder: (_, index) {
                    if (index == state.results.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    return _SearchResultTile(product: state.results[index]);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// __________________________search result body sub widgets.

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final query = context.select<SearchCubit, String>((c) => c.state.query);
    final cartCubit = context.read<CartCubit>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // ── Product image ──
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppNetworkImage(product.imageUrl, cacheWidth: 200),
            ),
            const Gap(12),

            // ── Favorite button ──
            FavoriteButton(
              cubit: context.read<FavoritesCubit>(),
              product: product,
              size: 30,
              backgroundColor: AppColors.surface,
            ),
            const Gap(14),

            // ── Info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name with highlight
                  _HighlightText(
                    text: product.name,
                    query: query,
                    baseStyle: AppTextStyles.labelLarge,
                  ),
                  const Gap(4),

                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: CustomText(
                      text: product.categoryName,
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                    ),
                  ),
                  const Gap(6),

                  // Rating + votes
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFA726)),
                      const Gap(3),
                      CustomText(
                        text: product.rating.toStringAsFixed(1),
                        style: AppTextStyles.bodySmall,
                      ),
                      const Gap(4),
                      CustomText(text: '(${product.votes})', style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),

            // ── Price + Cart control ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  text: '\$${product.price.toStringAsFixed(2)}',
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary),
                ),
                const Gap(8),
                BlocBuilder<CartCubit, CartState>(
                  bloc: cartCubit,
                  builder: (context, cartState) {
                    final qty = cartCubit.quantityOf(product);
                    return qty == 0
                        ? _AddButton(product: product, cubit: cartCubit)
                        : _QtyControl(product: product, quantity: qty, cubit: cartCubit);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.product, required this.cubit});
  final ProductModel product;
  final CartCubit cubit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => cubit.addItem(product),
      child: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 18),
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  const _QtyControl({required this.product, required this.quantity, required this.cubit});
  final ProductModel product;
  final int quantity;
  final CartCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => cubit.removeItem(product),
            child: Icon(
              quantity > 1 ? Icons.remove_rounded : Icons.delete_outline_rounded,
              size: 15,
              color: AppColors.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: CustomText(
                text: '$quantity',
                key: ValueKey(quantity),
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => cubit.addItem(product),
            child: const Icon(Icons.add_rounded, size: 15, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

//..........................................

class _HighlightText extends StatelessWidget {
  const _HighlightText({required this.text, required this.query, this.baseStyle});

  final String text;
  final String query;
  final TextStyle? baseStyle;

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return CustomText(text: text, style: baseStyle ?? AppTextStyles.labelLarge);
    }

    final base = baseStyle ?? AppTextStyles.labelLarge;
    final highlight = base.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w700,
      backgroundColor: (AppColors.primary).withOpacity(0.1),
    );

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase().trim();
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: base));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: base));
      }
      spans.add(TextSpan(text: text.substring(index, index + lowerQuery.length), style: highlight));
      start = index + lowerQuery.length;
    }

    return RichText(text: TextSpan(children: spans));
  }
}
