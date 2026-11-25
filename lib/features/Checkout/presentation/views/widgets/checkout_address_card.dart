import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Address/data/models/address_model.dart';

/// Selected delivery address (tap to change) or a prompt to add one.
class CheckoutAddressCard extends StatelessWidget {
  const CheckoutAddressCard({super.key, required this.address, required this.onTap});

  final AddressModel? address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final address = this.address;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: address == null ? const _EmptyContent() : _AddressContent(address: address),
        ),
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add_location_alt_outlined, color: AppColors.primary),
        ),
        const Gap(12),
        const Expanded(
          child: CustomText(text: 'Add delivery address', style: AppTextStyles.titleSmall),
        ),
        const Icon(Icons.chevron_right_rounded, color: AppColors.grey500),
      ],
    );
  }
}

class _AddressContent extends StatelessWidget {
  const _AddressContent({required this.address});

  final AddressModel address;

  IconData get _icon => switch (address.label) {
    'Home' => Icons.home_rounded,
    'Work' => Icons.work_rounded,
    _ => Icons.location_on_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final details = address.details;
    final phone = address.phone;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_icon, color: AppColors.primary, size: 22),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(text: address.label, style: AppTextStyles.titleSmall),
              const Gap(4),
              CustomText(
                text: address.fullAddress,
                maxLines: 2,
                style: AppTextStyles.bodyMedium,
              ),
              if (details.isNotEmpty) ...[
                const Gap(4),
                CustomText(text: details, style: AppTextStyles.bodySmall),
              ],
              if (phone != null && phone.isNotEmpty) ...[
                const Gap(4),
                CustomText(text: phone, style: AppTextStyles.bodySmall),
              ],
            ],
          ),
        ),
        const Gap(8),
        Text(
          'Change',
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}
