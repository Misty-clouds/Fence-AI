import 'package:fence_ai/constants/styles/color.dart';
import 'package:fence_ai/constants/styles/text_styles.dart';
import 'package:flutter/material.dart';

class ShowSnackbar{
  static void showSnackbar(BuildContext context, String message,int? duration) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary1,
        content: Center(child: Text(message,textAlign: TextAlign.center,style: AppTextStyles.regularTextBold())),
        duration: Duration(seconds: duration??2),
      ),
    );
  }
}
