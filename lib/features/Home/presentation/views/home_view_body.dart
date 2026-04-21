import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:sooq/features/Home/presentation/views/widgets/cart_bar.dart';
import 'package:sooq/features/Home/presentation/views/widgets/category_section.dart';
import 'package:sooq/features/Home/presentation/views/widgets/home_banner.dart';
import 'package:sooq/features/Home/presentation/views/widgets/products_section.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
      ),
    );
  }
}
