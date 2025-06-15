import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ResponsiveSize {
  static double getFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1200) {
      return baseSize * 1.2;
    } else if (screenWidth > 600) {
      return baseSize * 1.1;
    } else {
      return baseSize;
    }
  }
}

class AppColors {
  static const primaryDark = Colors.deepPurple;
  static const primary = Color(0xFF4527A0);
  static const primaryLight = Colors.deepPurpleAccent;
  static const catNotSelectedBG = Color.fromARGB(255, 227, 216, 247);
  static const catNotSelectedTXT = Colors.deepPurple;

  static const accent = Colors.pinkAccent;
  static const accentLight = Color(0xFFFF80AB);

  static const success = Colors.green;
  static const warning = Colors.orange;
  static const error = Colors.red;

  static const white = Colors.white;
  static const black = Colors.black;
  static const grey = Colors.grey;
  static const transparent = Colors.transparent;
}

class AppTextStyles {
  // Headings
  static TextStyle titleLarge(BuildContext context) => TextStyle(
    fontSize: ResponsiveSize.getFontSize(context, 20.sp),
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static TextStyle titleMedium(BuildContext context) => TextStyle(
    fontSize: ResponsiveSize.getFontSize(context, 18.sp),
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  // Body text
  static TextStyle bodyText(BuildContext context) => TextStyle(
    fontSize: ResponsiveSize.getFontSize(context, 16.sp),
    color: AppColors.white,
  );

  static TextStyle bodyTextDark(BuildContext context) => TextStyle(
    fontSize: ResponsiveSize.getFontSize(context, 14.sp),
    color: AppColors.primaryDark,
  );

  // Card text
  static TextStyle cardTitle(BuildContext context) => TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: ResponsiveSize.getFontSize(context, 12.sp),
    color: AppColors.primaryDark,
  );

  static TextStyle priceText(BuildContext context) => TextStyle(
    color: AppColors.success,
    fontWeight: FontWeight.bold,
    fontSize: ResponsiveSize.getFontSize(context, 12.sp),
  );

  // Button text
  static TextStyle buttonText(BuildContext context) => TextStyle(
    fontSize: ResponsiveSize.getFontSize(context, 14.sp),
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle priceTextLarge(BuildContext context) => TextStyle(
    color: AppColors.success,
    fontWeight: FontWeight.bold,
    fontSize: ResponsiveSize.getFontSize(context, 16.sp),
  );
}

class AppDecorations {
  static BoxDecoration sidebarContainer(BuildContext context) => BoxDecoration(
    color: Colors.deepPurple[700],
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.primaryLight, width: 1),
  );

  static BoxDecoration mainContainer(BuildContext context) => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: AppColors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration gridTileDecoration(BuildContext context) => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration selectedItemDecoration = BoxDecoration(
    color: AppColors.accentLight.withOpacity(0.3),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.accent,
      width: 1.5,
    ),
  );

  static BoxDecoration primaryButton = BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(30),
  );

  static BoxDecoration secondaryButton = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(30),
    border: Border.all(
      color: AppColors.primary,
      width: 1.5,
    ),
  );
}

class AppShadows {
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
}
