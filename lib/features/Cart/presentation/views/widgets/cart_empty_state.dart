import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_button.dart';
import 'package:sooq/core/utils/custom_text.dart';

class CartEmptyState extends StatefulWidget {
  const CartEmptyState({super.key});

  @override
  State<CartEmptyState> createState() => _CartEmptyStateState();
}

class _CartEmptyStateState extends State<CartEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _bounce = Tween<double>(
      begin: 0,
      end: -12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Animated basket illustration ──
          AnimatedBuilder(
            animation: _bounce,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _bounce.value),
              child: child,
            ),
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: AppColors.shadowMd,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
          ),
          const Gap(32),

          const CustomText(
            text: 'Your basket is empty',
            align: TextAlign.center,
            style: AppTextStyles.titleLarge,
          ),
          const Gap(10),
          const CustomText(
            text:
                'Looks like you haven\'t added anything yet.\nLet\'s fix that!',
            style: AppTextStyles.bodyMedium,
            align: TextAlign.center,
          ),
          const SizedBox(height: 36),

          CustomButton(
            radius: 16,
            onPressed: () => context.pop(),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.storefront_outlined,
                  color: AppColors.white,
                  size: 18,
                ),
                Gap(8),
                CustomText(text: 'Start Shopping', style: AppTextStyles.button),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
