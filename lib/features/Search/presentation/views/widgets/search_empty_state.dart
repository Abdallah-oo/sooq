import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_button.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Search/presentation/cubit/search_cubit.dart';

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<SearchCubit>().state;
    final hasFilters = state.filter.hasActiveFilters;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: AppColors.shadowMd,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 52,
              color: AppColors.grey300,
            ),
          ),
          const Gap(28),

          const CustomText(text: 'No results found',
            style: AppTextStyles.titleLarge,
          )

           ,
          const Gap(10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.bodyMedium,
              children: [
                const TextSpan(text: 'We couldn\'t find anything for '),
                TextSpan(
                  text: '"${state.query}"',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),

          if (hasFilters) ...[
            const Gap(8),
            const CustomText(
              text: 'Try removing some filters.',
              style: AppTextStyles.bodyMedium,
              align: TextAlign.center,
            ),
            const Gap(20),
            OutlinedButton.icon(
              onPressed: () =>
                  context.read<SearchCubit>().applyFilter(const SearchFilter()),
              icon: const Icon(
                Icons.filter_alt_off_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              label: CustomText(
                text: 'Clear filters',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ],

          const Gap(20),
          CustomButton(
            radius: 14,
            onPressed: () => context.read<SearchCubit>().clearQuery(),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(text: 'Search again', style: AppTextStyles.button),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
