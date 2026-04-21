import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

    static const List<String> _banners = [
    'assets/img/panner/Slider1.png',
    'assets/img/panner/Slider2.png',
    'assets/img/panner/Slider3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: _banners.length,
      itemBuilder: (_, index, __) => Image.asset(_banners[index]),
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