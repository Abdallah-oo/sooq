import 'package:flutter/material.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/features/Home/presentation/views/home_view_body.dart';
import 'package:sooq/features/Home/presentation/views/widgets/home_app_bar.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      appBar:  HomeAppBar(address: '61 Hopper Street'),
      body: HomeViewBody(),
    

    );
  }
}
