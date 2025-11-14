import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fence_ai/constants/styles/color.dart';

class AppTextStyles {

  // Label styles - For large text and splashcreens
  static TextStyle labelLarge({Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w700,
      fontSize: 62,
      height: 0.96,
      letterSpacing: -2.48,
      color: color ?? AppColors.secondary2,
    );
  }

  static TextStyle labelMedium({Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w600,
      fontSize: 22,
      color: color ?? AppColors.text1,
    );
  }


  static TextStyle labelSubtitle({Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: color ?? AppColors.text1,
    );
  }

  // Title styles
  static TextStyle titleLarge({Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w600,
      fontSize: 32,
      letterSpacing: -1.28,
      color: color ?? AppColors.text1,
    );
  }

   static TextStyle titleMedium({Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w600,
      fontSize: 22,
      letterSpacing: -0.88,
      color: color ?? AppColors.text1,
    );
  }
  
  static TextStyle titleSmall({Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: color ?? AppColors.text1,
    );
  }

    static TextStyle subTitle({Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: color ?? AppColors.text2,
    );
  }

 static TextStyle regularText({Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: color ?? AppColors.text2,
    );
  }   

   static TextStyle regularTextBold({Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: color ?? AppColors.text2,
    );
  } 


}
