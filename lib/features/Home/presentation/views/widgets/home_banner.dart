import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sooq/core/widgets/app_network_image.dart';
import 'package:sooq/features/Home/presentation/cubits/home_cubit/home_cubit.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final banners = context.select((HomeCubit c) => c.state.banners);
    if (banners.isEmpty) return const SizedBox(height: 150);
    return CarouselSlider.builder(
      itemCount: banners.length,
      itemBuilder: (_, index, __) =>
          AppNetworkImage(banners[index].imageUrl, cacheWidth: 700),
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
  }
}
