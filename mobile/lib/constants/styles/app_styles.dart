import 'package:fence_ai/constants/styles/color.dart';
import 'package:flutter/material.dart';

class AppStyles {
  // Rounded button style
  static ButtonStyle roundedButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    double? width,
    double? height,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppColors.secondary2,
      foregroundColor: foregroundColor ?? AppColors.primary3,
      minimumSize: Size(width ?? 358, height ?? 48),
      maximumSize: const Size(480, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  // Input decoration styles
  static InputDecoration inputDecorationWhite({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.text3,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondary2, width: 1),
      ),
      contentPadding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(
        minHeight: 56,
      ),
    );
  }
}