import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';

/// Centered icon + title + message (+ optional action).
/// Used for empty lists and full-screen errors.
class MessageState extends StatelessWidget {
  const MessageState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: AppColors.grey300),
            const Gap(16),
            CustomText(text: title, style: AppTextStyles.titleMedium, align: TextAlign.center),
            const Gap(8),
            CustomText(
              text: message,
              maxLines: 3,
              align: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            if (actionLabel != null) ...[
              const Gap(16),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
