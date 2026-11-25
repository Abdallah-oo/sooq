import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';

/// Promo code input. The code is validated by the server (`quote_order`):
/// this widget only collects the text and shows the result it is given.
class PromoCodeField extends StatefulWidget {
  const PromoCodeField({
    super.key,
    required this.appliedCode,
    required this.isLoading,
    required this.onApply,
    required this.onRemove,
    this.errorText,
  });

  /// Code accepted by the server (null when none is applied).
  final String? appliedCode;
  final bool isLoading;
  final String? errorText;
  final ValueChanged<String> onApply;
  final VoidCallback onRemove;

  @override
  State<PromoCodeField> createState() => _PromoCodeFieldState();
}

class _PromoCodeFieldState extends State<PromoCodeField> {
  final TextEditingController _controller = TextEditingController();

  bool get _isApplied => widget.appliedCode != null;
  bool get _hasError => widget.errorText != null && !_isApplied;

  @override
  void didUpdateWidget(PromoCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final applied = widget.appliedCode;
    if (applied != null && _controller.text.trim().toUpperCase() != applied) {
      _controller.text = applied;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    final code = _controller.text.trim();
    if (code.isEmpty || widget.isLoading) return;
    FocusScope.of(context).unfocus();
    widget.onApply(code);
  }

  void _remove() {
    FocusScope.of(context).unfocus();
    _controller.clear();
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: _isApplied ? AppColors.primaryLight : AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isApplied
                        ? AppColors.primary
                        : _hasError
                        ? AppColors.error
                        : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  readOnly: _isApplied || widget.isLoading,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _apply(),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: _isApplied ? AppColors.primary : AppColors.primaryText,
                    letterSpacing: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Promo code',
                    hintStyle: AppTextStyles.bodyMedium,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    suffixIcon: _isApplied
                        ? GestureDetector(
                            onTap: widget.isLoading ? null : _remove,
                            child: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.secondaryText,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const Gap(10),
            if (_isApplied)
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.white),
              )
            else
              GestureDetector(
                onTap: _apply,
                child: Container(
                  height: 50,
                  constraints: const BoxConstraints(minWidth: 76),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.shadowPrimary,
                  ),
                  alignment: Alignment.center,
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text('Apply', style: AppTextStyles.button),
                ),
              ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    widget.errorText!,
                    style: AppTextStyles.caption.copyWith(color: AppColors.error),
                  ),
                )
              : _isApplied
              ? Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    'Promo code applied successfully!',
                    style: AppTextStyles.caption.copyWith(color: AppColors.success),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
