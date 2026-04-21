import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/constances/category_constants.dart';
import 'package:sooq/core/constances/product_constants.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Favorite/presentation/cubit/favorites_cubit.dart';
import 'package:sooq/features/Favorite/presentation/views/widgets/favorite_btn.dart';
import 'package:sooq/features/Home/data/models/products_model.dart';
import 'package:sooq/features/Cart/presentation/cubits/cart_cubit.dart';
import 'package:sooq/features/Home/presentation/cubits/category_cubit.dart';

class ProductsSection extends StatelessWidget {
  const ProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        final index = state.selectedIndex;
        final categoryName = CategoryConstants.items[index].name;
        final products = ProductConstants.byIndex(index);

        return Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(
                    text: categoryName,
                    style: AppTextStyles.titleMedium,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                    },
                    child: CustomText(
                      text: 'See all',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const Gap(5),
                ],
              ),
              const Gap(12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: products
                      .map((p) => _ProductCard(product: p))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
//product section sub widgets ----------------------------------------------------------------

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.shadowMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 110,
                    width: double.infinity,
                    color: AppColors.white,
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(product.image),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: FavoriteButton(
                      cubit: context.read<FavoritesCubit>(),
                      product: product,
                      size: 30,
                      backgroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: product.name,
                    style: AppTextStyles.labelLarge,
                  ),

                  const Gap(4),

                  // Rating row
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFFFA726),
                      ),
                      const Gap(3),
                      CustomText(
                        text: product.rate.toStringAsFixed(1),
                        style: AppTextStyles.bodySmall,
                      ),
                      const Gap(4),
                      CustomText(
                        text: '(${product.votes})',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const Gap(8),

                  // Price + Add/Remove
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: '\$${product.price.toStringAsFixed(0)}',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),

                      BlocBuilder<CartCubit, CartState>(
                        builder: (context, state) {
                          final qty = context.read<CartCubit>().quantityOf(
                            product,
                          );
                          return qty == 0
                              ? _AddButton(product: product)
                              : _QuantityControl(
                                  product: product,
                                  quantity: qty,
                                );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<CartCubit>().addItem(product),
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: AppColors.white, size: 18),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.product, required this.quantity});
  final Product product;
  final int quantity;

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
            onTap: () => context.read<CartCubit>().removeItem(product),
            child: Icon(
              quantity > 1 ? Icons.remove : Icons.delete_outline_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$quantity',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.read<CartCubit>().addItem(product),
            child: const Icon(Icons.add, size: 16, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
