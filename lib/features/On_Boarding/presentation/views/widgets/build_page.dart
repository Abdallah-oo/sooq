import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/extensions/responsive.dart';

import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_button.dart';
import 'package:sooq/core/utils/custom_text.dart';

class BuildPage extends StatelessWidget {
  const BuildPage({
    super.key,
    required this.index,
    required this.images,
    required this.pages,
    required this.currentIndex,
    required this.controller,
  });

  final int index;
  final int currentIndex;
  final List<ImageProvider> images;
  final List<Map<String, String>> pages;
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 1.1, end: 1.0),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Image(
                  width: double.infinity,
                  image: ResizeImage(
                    images[index] as AssetImage,
                    width: context.screenWidth.toInt(),
                  ),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              );
            },
          ),
        ),

        Positioned(
          right: 0,
          left: 0,
          bottom: 40,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: AppColors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(28),
              // boxShadow: AppColors.shadowMd,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: pages[index]['title']!,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.white
                   
                  ),
                ),

                const Gap(10),
                CustomText(
                  maxLines: 2,
                  align: TextAlign.center,
                  text: pages[index]['subtitle']!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey100,
                  ),
                ),

                const Gap(20),

                _AnimatedIndicator(
                  currentIndex: currentIndex,
                  length: pages.length,
                ),

                const SizedBox(height: 20),

                _ProButton(
                  currentIndex: currentIndex,
                  pages: pages,
                  controller: controller,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// INDICATOR

class _AnimatedIndicator extends StatelessWidget {
  const _AnimatedIndicator({required this.currentIndex, required this.length});

  final int currentIndex;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(length, (index) {
        final isActive = index <= currentIndex;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isActive ? AppColors.primaryLight : Colors.grey.shade300,
            ),
          ),
        );
      }),
    );
  }
}

/// BUTTON
class _ProButton extends StatelessWidget {
  const _ProButton({
    required this.currentIndex,
    required this.pages,
    required this.controller,
  });

  final int currentIndex;
  final List pages;
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    final isLast = currentIndex == pages.length - 1;

    return CustomButton(
      color: AppColors.primaryLight,
      onPressed: () {
        if (isLast) {
          context.pushReplacement(Routes.login);
        } else {
          controller.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
          );
        }
      },
      radius: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
            text: isLast ? 'Start Shopping' : 'Next',
            style: AppTextStyles.button.copyWith(
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
