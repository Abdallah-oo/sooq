import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const Gap(30),
              _buildSection(
                title: 'My Account',
                items: [
                  _buildMenuTile(
                    icon: Icons.person_outline,
                    iconColor: Colors.blue,
                    title: 'My Profile',
                    onTap: () {
                      // Navigate to Profile Page
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.receipt_long_outlined,
                    iconColor: Colors.orange,
                    title: 'My Orders',
                    onTap: () {},
                  ),
                  _buildMenuTile(
                    icon: Icons.location_on_outlined,
                    iconColor: Colors.purple,
                    title: 'My Addresses',
                    onTap: () {},
                  ),
                ],
              ),
              const Gap(16),
              _buildSection(
                title: 'App Settings',
                items: [
                  _buildMenuTile(
                    icon: Icons.notifications_outlined,
                    iconColor: AppColors.error,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  _buildMenuTile(
                    icon: Icons.language_outlined,
                    iconColor: Colors.teal,
                    title: 'Language',
                    onTap: () {},
                  ),
                ],
              ),
              const Gap(16),
              _buildSection(
                title: 'Support',
                items: [
                  _buildMenuTile(
                    icon: Icons.headset_mic_outlined,
                    iconColor: Colors.green,
                    title: 'Customer Service',
                    onTap: () {},
                  ),
                  _buildMenuTile(
                    icon: Icons.policy_outlined,
                    iconColor: Colors.grey,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _buildMenuTile(
                    icon: Icons.info_outline,
                    iconColor: Colors.indigo,
                    title: 'About Us',
                    onTap: () {},
                  ),
                ],
              ),
              const Gap(24),
              _buildMenuTile(
                icon: Icons.logout,
                iconColor: AppColors.error,
                title: 'Logout',
                isLogout: true,
                onTap: () => context.pushReplacement(Routes.login),
              ),
              const Gap(100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: CustomText(text: title, style: AppTextStyles.titleMedium),
        ),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias, // يقص الـ ripple عند الحواف المدورة
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color.lerp(AppColors.white, iconColor, 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: CustomText(
        text: title,
        style: AppTextStyles.labelMedium.copyWith(
          color: isLogout ? AppColors.error : Colors.black87,
        ),
      ),

      trailing: isLogout
          ? null
          : const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey500),
      onTap: onTap,
    );
  }
}
