import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';

enum _PromoStatus { idle, applied, invalid }

class PromoCodeField extends StatefulWidget {
  const PromoCodeField({super.key, required this.onApplied});

  final void Function(double discount) onApplied;

  @override
  State<PromoCodeField> createState() => _PromoCodeFieldState();
}

class _PromoCodeFieldState extends State<PromoCodeField> {
  final _controller = TextEditingController();
  final _status = ValueNotifier<_PromoStatus>(_PromoStatus.idle);

  // Hardcoded demo codes — replace with a Supabase lookup in production
  static const Map<String, double> _validCodes = {
    'TABANJA1': 0.10,
    'TABANJA2': 0.20,
    'TABANJA3': 0.15,
  };

  @override
  void dispose() {
    _controller.dispose();
    _status.dispose();
    super.dispose();
  }

  void _apply() {
    final code = _controller.text.trim().toUpperCase();
    final discount = _validCodes[code];

    if (discount != null) {
      _status.value = _PromoStatus.applied;
      widget.onApplied(discount);
    } else {
      _status.value = _PromoStatus.invalid;
    }
  }

  void _clear() {
    FocusScope.of(context).unfocus();
    _controller.clear();
    _status.value = _PromoStatus.idle;
    widget.onApplied(0.0);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_PromoStatus>(
      valueListenable: _status,
      builder: (_, status, __) {
        final isApplied = status == _PromoStatus.applied;
        final isInvalid = status == _PromoStatus.invalid;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: isApplied
                          ? AppColors.primaryLight.withOpacity(0.4)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isApplied
                            ? AppColors.primary
                            : isInvalid
                            ? AppColors.error
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      readOnly: isApplied,
                      textCapitalization: TextCapitalization.characters,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isApplied
                            ? AppColors.primary
                            : AppColors.primaryText,
                        letterSpacing: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Promo code',
                        hintStyle: AppTextStyles.bodyMedium,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: isApplied
                            ? GestureDetector(
                                onTap: () => _clear(),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: AppColors.secondaryText,
                                ),
                              )
                            : null,
                      ),
                      onChanged: (_) {
                        if (isInvalid) _status.value = _PromoStatus.idle;
                      },
                    ),
                  ),
                ),
                const Gap(10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isApplied
                      ? Container(
                          key: const ValueKey('check'),
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: AppColors.white,
                          ),
                        )
                      : GestureDetector(
                          key: const ValueKey('apply'),
                          onTap: _apply,
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: AppColors.shadowPrimary,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Apply',
                              style: AppTextStyles.button,
                            ),
                          ),
                        ),
                ),
              ],
            ),

            // Error message
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: isInvalid
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        'Invalid promo code. Please try again.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Success message
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: isApplied
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        'Promo code applied successfully!',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}
