import 'package:flutter/material.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.hint,
    this.secure,
    this.keyboardType,
    this.controller,
    this.validation,
    this.suffixIcon,
    this.prefixIcon,
    this.onChange,
    this.color,
    this.textStyle,
    this.borderColor,
    this.cursorColor,
    this.maxLines,
    this.minLines,
  });

  final bool? secure;
  final String hint;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validation;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final void Function(String)? onChange;
  final Color? color;
  final TextStyle? textStyle;
  final Color? borderColor;
  final Color? cursorColor;
  final int? maxLines;
  final int? minLines;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextDirection _currentDirection;

  @override
  void initState() {
    super.initState();
    _currentDirection = _detectDirection(widget.controller?.text ?? '');
  }

  TextDirection _detectDirection(String text) {
    final trimmed = text.trimLeft();
    if (trimmed.isEmpty) return TextDirection.ltr;
    return RegExp(r'[\u0600-\u06FF]').hasMatch(trimmed[0])
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  void _handleChange(String value) {
    final newDirection = _detectDirection(value);
    if (newDirection != _currentDirection) {
      setState(() => _currentDirection = newDirection);
    }
    widget.onChange?.call(value);
  }

  InputDecoration _buildDecoration() {
    return InputDecoration(
      hintText: widget.hint,
      hintStyle: widget.textStyle,
      suffixIcon: widget.suffixIcon,
      prefixIcon: widget.prefixIcon,
      filled: true,
      fillColor: widget.color ?? AppColors.white,
      contentPadding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: widget.borderColor ??AppColors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: widget.borderColor ?? AppColors.white),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
    borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      errorStyle: const TextStyle(
        color:AppColors.error,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      prefixIconColor: AppColors.grey500,
      suffixIconColor:AppColors.grey700,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
         
          controller: widget.controller,
          minLines: widget.minLines,
          maxLines: widget.secure == true ? 1 : widget.maxLines,
          obscureText: widget.secure ?? false,
          keyboardType: widget.keyboardType ?? TextInputType.text,
          style:
              widget.textStyle ??
                AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText),
          textDirection: _currentDirection,
          cursorColor: widget.cursorColor ?? AppColors.grey700,
          cursorHeight: 15,
          cursorOpacityAnimates: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.validation,
          onChanged: _handleChange,
          decoration: _buildDecoration(),
        ),
      ],
    );
  }
}
