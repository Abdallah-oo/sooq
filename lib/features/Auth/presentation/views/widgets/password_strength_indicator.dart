
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_text.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({super.key, required this.passwordNotifier});

  final ValueNotifier<String> passwordNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: passwordNotifier,
      builder: (_, password, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StrengthRow(
              met: password.length >= 8,
              label: 'At least 8 characters',
            ),
            const SizedBox(height: 6),
            _StrengthRow(
              met: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
              label: 'Has special character (!@#...)',
            ),
            const SizedBox(height: 6),
            _StrengthRow(
              met: password.contains(RegExp(r'[A-Z]')),
              label: 'Has uppercase letter',
            ),
            const SizedBox(height: 6),
            _StrengthRow(
              met: password.contains(RegExp(r'[a-z]')),
              label: 'Has lowercase letter',
            ),
            const SizedBox(height: 6),
            _StrengthRow(
              met: password.contains(RegExp(r'[0-9]')),
              label: 'Has a number',
            ),
          ],
        );
      },
    );
  }
}

class _StrengthRow extends StatelessWidget {
  const _StrengthRow({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: met ? AppColors.success : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: met ? AppColors.success : AppColors.grey300,
              width: 1.5,
            ),
          ),
          child: met
              ? const Icon(Icons.check, size: 10, color: AppColors.white)
              : null,
        ),
        const Gap(8),

        CustomText(text: label, style: AppTextStyles.bodySmall.copyWith(
            color: met ? AppColors.white : AppColors.grey300,
          ),)
       
      ],
    );
  }
}

