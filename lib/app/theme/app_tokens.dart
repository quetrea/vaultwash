import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF4F4F1);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF0F1EC);
  static const surfaceRaised = Color(0xFFFBFBF8);
  static const border = Color(0xFFDCDDD5);
  static const borderStrong = Color(0xFFC9CBC2);
  static const textPrimary = Color(0xFF171918);
  static const textSecondary = Color(0xFF5B615D);
  static const textMuted = Color(0xFF7A807D);
  static const accent = Color(0xFF215646);
  static const accentSoft = Color(0xFFE6F0EC);
  static const success = Color(0xFF2E6F53);
  static const warning = Color(0xFF8C6323);
  static const danger = Color(0xFF8A3D3D);
}

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
}

abstract final class AppRadius {
  static final sm = BorderRadius.circular(10);
  static final md = BorderRadius.circular(14);
  static final lg = BorderRadius.circular(18);
}

abstract final class AppBorders {
  static const subtle = BorderSide(color: AppColors.border);
  static const strong = BorderSide(color: AppColors.borderStrong);
}

abstract final class AppDurations {
  static const quick = Duration(milliseconds: 120);
  static const standard = Duration(milliseconds: 200);
}
