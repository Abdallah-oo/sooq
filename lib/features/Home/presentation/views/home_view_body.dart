import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sooq/core/extensions/responsive.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Home/data/models/product_model.dart';
import 'package:sooq/features/Home/presentation/cubits/home_cubit/home_cubit.dart';
import 'package:sooq/features/Home/presentation/views/widgets/cart_bar.dart';
import 'package:sooq/features/Home/presentation/views/widgets/category_section.dart';
import 'package:sooq/features/Home/presentation/views/widgets/home_banner.dart';
import 'package:sooq/features/Home/presentation/views/widgets/product_card.dart';
import 'package:sooq/features/Home/presentation/views/widgets/products_section.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.categories.isNotEmpty && state.banners.isNotEmpty && !state.isLoading) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(12),

                      // ── Banner Carousel ──
                      Builder(
                        builder: (context) {
                          return const HomeBanner();
                        },
                      ),

                      const Gap(28),

                      // ── Categories + Products ──
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CategorySection(),
                          Gap(28),
                          ProductsSection(),
                          Gap(200), // space for cart bar
                        ],
                      ),
                    ],
                  ),
                ),
                const Positioned(bottom: 100, left: 10, right: 10, child: CartBar()),
              ],
            );
          } else {
            return const _HomeViewBodyLoading();
          }
        },
      ),
    );
  }
}

class _HomeViewBodyLoading extends StatelessWidget {
  const _HomeViewBodyLoading();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(12),

                // ── Banner Carousel ──
                Builder(
                  builder: (context) {
                    return CarouselSlider.builder(
                      itemCount: 3,
                      itemBuilder: (_, index, __) => Image.asset('assets/img/test.webp'),
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        viewportFraction: 0.7,
                        autoPlayInterval: const Duration(seconds: 3),
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                ),

                const Gap(28),

                // ── Categories + Products ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(text: 'Categories', style: AppTextStyles.titleMedium),
                          const Gap(16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                5,
                                (i) => Padding(
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
                                          color: AppColors.surface,
                                          border: Border.all(color: AppColors.primary),
                                        ),
                                        child: Image.asset('assets/img/test.webp'),
                                      ),
                                      const Gap(8),
                                      const AnimatedDefaultTextStyle(
                                        duration: Duration(milliseconds: 200),
                                        style: AppTextStyles.labelMedium,
                                        child: CustomText(text: 'category'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(28),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CustomText(text: 'category', style: AppTextStyles.titleMedium),
                              const Spacer(),

                              CustomText(
                                text: 'See all',
                                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                              ),

                              const Gap(5),
                            ],
                          ),
                          const Gap(12),
                          SizedBox(
                            height: context.screenHeight * 0.28,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => const ProductCard(
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Positioned(bottom: 100, left: 10, right: 10, child: CartBar()),
        ],
      ),
    );
  }
}
