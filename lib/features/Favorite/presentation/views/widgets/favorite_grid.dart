import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Cart/presentation/cubits/cart_cubit.dart';
import 'package:sooq/features/Favorite/presentation/cubit/favorites_cubit.dart';
import 'package:sooq/features/Favorite/presentation/views/widgets/favorite_btn.dart';
import 'package:sooq/features/Home/data/models/products_model.dart';

class FavoritesGrid extends StatelessWidget {
  const FavoritesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      buildWhen: (p, c) => p.favorites != c.favorites,
      builder: (context, state) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _StaggeredEntrance(
                    index: index,
                    child: _FavoritesCard(product: state.favorites[index]),
                  ),
                  childCount: state.favorites.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
              ),
            ),
        
          ],
        );
      },
    );
  }
}

// ── Staggered entrance animation per grid item ──
class _StaggeredEntrance extends StatefulWidget {
  const _StaggeredEntrance({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<_StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<_StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Stagger: first 8 items animate in sequence, rest appear immediately
    final delay = widget.index < 8
        ? Duration(milliseconds: widget.index * 60)
        : Duration.zero;
    Future.delayed(delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── Favorite card ──
class _FavoritesCard extends StatelessWidget {
  const _FavoritesCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('fav-${product.name}'),
      direction: DismissDirection.up,
      onDismissed: (_) => context.read<FavoritesCubit>().remove(product),
      background: _DismissUpBackground(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ──
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  // Product image with Hero
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: AppColors.surface,
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(product.image, fit: BoxFit.contain),
                    ),
                  ),

                  // ── Favorite button — top right ──
                  Positioned(
                    top: 8,
                    right: 8,
                    child: FavoriteButton(
                      cubit: context.read<FavoritesCubit>(),
                      product: product,
                      size: 32,
                      backgroundColor: AppColors.white,
                    ),
                  ),

                  // ── Category tag — top left ──
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomText(
                        text: product.category,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info area ──
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
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
                          size: 13,
                          color: Color(0xFFFFA726),
                        ),
                        const Gap(4),
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

                    const Spacer(),

                    // Price + Add to cart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: '\$${product.price.toStringAsFixed(0)}',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        _CartButton(product: product),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Swipe-up background ──
class _DismissUpBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Gap(16),
          Icon(
            Icons.favorite_border_rounded,
            color: AppColors.error.withOpacity(0.7),
            size: 28,
          ),
          const Gap(4),
          CustomText(
            text: 'Remove',
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

// ── Add to cart button on the card ──
class _CartButton extends StatelessWidget {
  const _CartButton({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    return BlocBuilder<CartCubit, CartState>(
      bloc: cartCubit,
      builder: (context, state) {
        final qty = cartCubit.quantityOf(product);
        if (qty == 0) {
          return GestureDetector(
            onTap: () => cartCubit.addItem(product),
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.white,
                size: 17,
              ),
            ),
          );
        }
        // Show quantity badge when already in cart
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: CustomText(
            text: '×$qty',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }
}
