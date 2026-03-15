import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fence_ai/constants/styles/color.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary1,
        secondary: AppColors.secondary1,
        tertiary: AppColors.primary3,
        surface: AppColors.text3,
        error: AppColors.error,
        onPrimary: AppColors.text3,
        onSecondary: AppColors.text1,
        onSurface: AppColors.text1,
        onError: AppColors.text3,
        outline: AppColors.stroke,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.text3,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.text3,
        foregroundColor: AppColors.text1,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          letterSpacing: -0.88,
          color: AppColors.text1,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        // Display styles (for large text)
        displayLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 62,
          letterSpacing: -2.48,
          color: AppColors.text1,
        ),
        
        // Title styles
        titleLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 32,
          letterSpacing: -1.28,
          color: AppColors.text1,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          letterSpacing: -0.88,
          color: AppColors.text1,
        ),
        titleSmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: AppColors.text1,
        ),
        
        // Body styles
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: AppColors.text2,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: AppColors.text2,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: AppColors.text2,
        ),
        
        // Label styles
        labelLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: AppColors.text1,
        ),
        labelMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: AppColors.text1,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: AppColors.text2,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary2,
          foregroundColor: AppColors.primary3,
          minimumSize: const Size(358, 48),
          maximumSize: const Size(480, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary1,
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary1,
          side: const BorderSide(color: AppColors.primary1, width: 1.5),
          minimumSize: const Size(358, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.text3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.stroke, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary1, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: AppColors.text2,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: AppColors.text2,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: AppColors.text3,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.stroke,
        thickness: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.primary1,
        size: 24,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary1,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: AppColors.text3,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary1;
          }
          return AppColors.text3;
        }),
        checkColor: WidgetStateProperty.all(AppColors.text3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary1;
          }
          return AppColors.text2;
        }),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary1;
          }
          return AppColors.text2;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.secondary1;
          }
          return AppColors.stroke;
        }),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary1,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.text3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          letterSpacing: -0.88,
          color: AppColors.text1,
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: AppColors.text2,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.text3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
    );
  }
}
