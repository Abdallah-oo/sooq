import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/features/Address/data/models/address_model.dart';

enum AddressMenuAction { edit, setDefault, delete }

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
    required this.onMenuAction,
    this.onTap,
  });

  final AddressModel address;
  final ValueChanged<AddressMenuAction> onMenuAction;

  /// Used in selection mode (checkout) to pick this address.
  final VoidCallback? onTap;

  IconData get _icon => switch (address.label) {
    'Home' => Icons.home_rounded,
    'Work' => Icons.work_rounded,
    _ => Icons.location_on_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
          child: Row(
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
                    Row(
                      children: [
                        Flexible(
                          child: CustomText(text: address.label, style: AppTextStyles.titleSmall),
                        ),
                        if (address.isDefault) ...[const Gap(8), const _DefaultBadge()],
                      ],
                    ),
                    const Gap(4),
                    CustomText(
                      text: address.fullAddress,
                      maxLines: 2,
                      style: AppTextStyles.bodyMedium,
                    ),
                    if (address.details.isNotEmpty) ...[
                      const Gap(4),
                      CustomText(text: address.details, style: AppTextStyles.bodySmall),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<AddressMenuAction>(
                icon: const Icon(Icons.more_vert, color: AppColors.grey500),
                color: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: onMenuAction,
                itemBuilder: (_) => [
                  const PopupMenuItem(value: AddressMenuAction.edit, child: Text('Edit')),
                  if (!address.isDefault)
                    const PopupMenuItem(
                      value: AddressMenuAction.setDefault,
                      child: Text('Set as default'),
                    ),
                  const PopupMenuItem(
                    value: AddressMenuAction.delete,
                    child: Text('Delete', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Default',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
