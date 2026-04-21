import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/constances/category_constants.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_button.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Search/presentation/cubit/search_cubit.dart';

class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const SearchFilterSheet()),
    );
  }

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late final ValueNotifier<SortBy> _sortBy;
  late final ValueNotifier<double?> _minRating;
  late final ValueNotifier<String?> _category;

  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-populate from current filter
    final filter = context.read<SearchCubit>().state.filter;
    _sortBy = ValueNotifier(filter.sortBy);
    _minRating = ValueNotifier(filter.minRating);
    _category = ValueNotifier(filter.category);
    if (filter.minPrice != null) {
      _minPriceCtrl.text = filter.minPrice!.toStringAsFixed(0);
    }
    if (filter.maxPrice != null) {
      _maxPriceCtrl.text = filter.maxPrice!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _sortBy.dispose();
    _minRating.dispose();
    _category.dispose();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    final minPrice = double.tryParse(_minPriceCtrl.text);
    final maxPrice = double.tryParse(_maxPriceCtrl.text);
    context.read<SearchCubit>().applyFilter(
      SearchFilter(
        sortBy: _sortBy.value,
        minRating: _minRating.value,
        category: _category.value,
        minPrice: minPrice,
        maxPrice: maxPrice,
      ),
    );
    Navigator.pop(context);
  }

  void _reset() {
    context.read<SearchCubit>().applyFilter(const SearchFilter());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // ── Handle ──
              const Gap(12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(16),

              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomText(
                      text: 'Filters',
                      style: AppTextStyles.titleLarge,
                    ),
                    TextButton(
                      onPressed: _reset,
                      child: CustomText(
                        text: 'Reset all',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border),

              // ── Scrollable content ──
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  children: [
                    // ── Sort by ──
                    const _SectionHeader(title: 'Sort by'),
                    const Gap(12),
                    ValueListenableBuilder<SortBy>(
                      valueListenable: _sortBy,
                      builder: (_, currentSort, __) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SortBy.values.map((sort) {
                          final selected = currentSort == sort;
                          return GestureDetector(
                            onTap: () => _sortBy.value = sort,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: CustomText(
                                text: _sortLabel(sort),
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: selected
                                      ? AppColors.white
                                      : AppColors.secondaryText,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Gap(28),

                    // ── Category ──
                    const _SectionHeader(title: 'Category'),
                    const Gap(12),
                    ValueListenableBuilder<String?>(
                      valueListenable: _category,
                      builder: (_, currentCategory, __) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _CategoryChip(
                            label: 'All',
                            selected: currentCategory == null,
                            onTap: () => _category.value = null,
                          ),
                          ...CategoryConstants.items.map((cat) {
                            return _CategoryChip(
                              label: cat.name,
                              selected: currentCategory == cat.name,
                              onTap: () => _category.value = cat.name,
                            );
                          }),
                        ],
                      ),
                    ),
                    const Gap(28),

                    // ── Price range ── 
                    const _SectionHeader(title: 'Price range'),
                    const Gap(12),
                    Row(
                      children: [
                        Expanded(
                          child: _PriceField(
                            controller: _minPriceCtrl,
                            hint: 'Min \$',
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('–', style: AppTextStyles.bodyMedium),
                        ),
                        Expanded(
                          child: _PriceField(
                            controller: _maxPriceCtrl,
                            hint: 'Max \$',
                          ),
                        ),
                      ],
                    ),
                    const Gap(28),

                    // ── Min rating ──
                    const _SectionHeader(title: 'Minimum rating'),
                    const Gap(12),
                    ValueListenableBuilder<double?>(
                      valueListenable: _minRating,
                      builder: (_, currentRating, __) => Column(
                        children: [1, 2, 3, 4].map((star) {
                          final rating = star.toDouble();
                          final selected = currentRating == rating;
                          return GestureDetector(
                            onTap: () =>
                                _minRating.value = selected ? null : rating,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primaryLight.withOpacity(0.4)
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ...List.generate(
                                      5,
                                      (i) => Icon(
                                        i < star
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        size: 18,
                                        color: const Color(0xFFFFA726),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '& up',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                    if (selected) ...[
                                      const Spacer(),
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Apply button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: CustomButton(
                  radius: 16,
                  onPressed: _apply,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Apply Filters', style: AppTextStyles.button),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _sortLabel(SortBy sort) {
    return switch (sort) {
      SortBy.relevance => 'Relevance',
      SortBy.priceLow => 'Price: Low → High',
      SortBy.priceHigh => 'Price: High → Low',
      SortBy.rating => 'Top Rated',
      SortBy.popularity => 'Most Popular',
    };
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) =>
      CustomText(text: title, style: AppTextStyles.titleSmall);
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: CustomText(
          text: label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? AppColors.white : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTextStyles.bodyLarge,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
