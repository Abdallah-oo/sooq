import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/widgets/app_network_image.dart';
import 'package:sooq/features/Home/data/models/category_model.dart';
import 'package:sooq/features/Home/presentation/cubits/category_cubit/category_cubit.dart';
import 'package:sooq/features/Home/presentation/cubits/home_cubit/home_cubit.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(text: 'Categories', style: AppTextStyles.titleMedium),
          const Gap(16),
          BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, state) {
              final categories = context.select((HomeCubit c) => c.state.categories);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    categories.length,
                    (i) => _CategoryItem(
                      category: categories[i],
                      isSelected: state.selectedIndex == i,
                      onTap: () => context.read<CategoryCubit>().selectCategory(i),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
//category section sub widgets ------------------------------------------------

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.category, required this.isSelected, required this.onTap});

  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 72,
              width: 72,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryLight : AppColors.surface,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected ? AppColors.shadowPrimary : null,
              ),
              child: AppNetworkImage(category.imageUrl, cacheWidth: 150),
            ),
            const Gap(8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: isSelected
                  ? AppTextStyles.labelLarge.copyWith(color: AppColors.primary)
                  : AppTextStyles.labelMedium,
              child: CustomText(text: category.name),
            ),
          ],
        ),
      ),
    );
  }
}
