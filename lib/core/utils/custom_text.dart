import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:sooq/core/theme/app_text_styles.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    this.style,
    this.align,
    this.maxLines,
    this.minFontSize,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? align;
  final int? maxLines;
  final double? minFontSize;

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      textAlign: align ?? TextAlign.start,
      style: style ?? AppTextStyles.bodyMedium,
      maxLines: maxLines ?? 1,
      minFontSize: minFontSize ?? 10,
      overflow: TextOverflow.ellipsis,
    );
  }
}
