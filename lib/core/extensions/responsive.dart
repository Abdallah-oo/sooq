import 'dart:math' as math;
import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  double responsiveWidth({
    double? screen,
    required double percentage,
    required double min,
    required double max,
  }) {
    return math.min(math.max((screen ?? screenWidth) * percentage, min), max);
  }

  double responsiveHeight({
    double? screen,
    required double percentage,
    required double min,
    required double max,
  }) {
    return math.min(math.max((screen ?? screenHeight) * percentage, min), max);
  }
}
