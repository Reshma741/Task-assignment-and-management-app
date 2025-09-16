import 'package:flutter/material.dart';

extension ColorExt on Color {
  /// Replacement for the deprecated `withOpacity` usage.
  /// Uses `Color.fromRGBO` to construct a color with the given opacity.
  Color withOpacitySafe(double opacity) {
  return withAlpha((opacity * 255).round());
  }
}
