import 'package:flutter/material.dart';
import 'package:sooq/core/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.radius,
    required this.child,
    this.onPressed,
    this.padding,

    this.color,
    this.borderSide,
    this.elevation,
  });
  final void Function()? onPressed;
  final EdgeInsetsGeometry? padding;
  final Widget child;
  final double radius;
  final Color? color;
  final BorderSide? borderSide;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
  style: ButtonStyle(
        elevation: WidgetStateProperty.all(0), // مهم
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),

        overlayColor: WidgetStateProperty.all(Colors.transparent),

        backgroundColor: WidgetStateProperty.all(
          color ?? AppColors.primary,
        ),

        padding: WidgetStateProperty.all(padding ?? const EdgeInsets.symmetric(vertical: 10)),

        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: borderSide ?? BorderSide.none,
          ),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: WidgetStateProperty.all(const Size(0, 0)),
      ),
      child: child,
    );
  }
}
