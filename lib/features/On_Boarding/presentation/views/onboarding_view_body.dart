import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/On_Boarding/presentation/views/widgets/build_page.dart';

class OnboardingViewBody extends StatefulWidget {
  const OnboardingViewBody({super.key});

  @override
  State<OnboardingViewBody> createState() => _OnboardingViewBodyState();
}

class _OnboardingViewBodyState extends State<OnboardingViewBody> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> pages = [
    {
      'image': 'assets/img/onboarding/b1.png',
      'title': 'Pure Freshness Daily',
      'subtitle': 'Premium-quality groceries, fresh produce, and essentials delivered to your doorstep with care.',
    },
    {
      'image': 'assets/img/onboarding/b2.png',
      'title': 'Instant Delivery Experience',
      'subtitle': 'From order to doorstep in record time — seamless, fast, and always reliable.',
    },
    {
      'image': 'assets/img/onboarding/b3.png',
      'title': 'Everything You Need',
      'subtitle': 'A complete hypermarket experience in one elegant app — food, essentials, and more.',
    },
  ];

  late final List<ImageProvider> images;

  @override
  void initState() {
    super.initState();
    images = pages.map((e) => AssetImage(e['image']!)).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: pages.length,
          onPageChanged: (index) {
            setState(() => currentIndex = index);
          },
          itemBuilder: (context, index) {
            return AnimatedSwitcher(
               duration: const Duration(milliseconds: 500),
              child: BuildPage(
                index: index,
                pages: pages,
                images: images,
                currentIndex: currentIndex,
                controller: _controller,
              ),
            );
          },
        ),
       Positioned(top: 10,right: 10,child: GestureDetector(
         onTap: () {
              context.pushReplacement(Routes.login);
            },
         child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
          ),
           child:  
             const CustomText(text: 'Skip',style:AppTextStyles.button,)
           
         
         ),
       ))
     
      ],
    );
  }
}
