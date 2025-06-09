import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/constants.dart';

class ActiveOrdersGrid extends StatelessWidget {
  final List<Map<String, dynamic>> activeOrders;
  final Function(Map<String, dynamic>)? onOrderTilePressed;

  const ActiveOrdersGrid({
    super.key,
    required this.activeOrders,
    this.onOrderTilePressed,
  });

  @override
  Widget build(BuildContext context) {
    if (activeOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40.sp,
              color: AppColors.white.withOpacity(0.5),
            ),
            SizedBox(height: 8.h),
            Text(
              'No active orders',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    // Sort orders in descending order by OrderNum
    final sortedOrders = List<Map<String, dynamic>>.from(activeOrders);
    sortedOrders.sort((a, b) => (b['OrderNum'] as int).compareTo(a['OrderNum'] as int));

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 1.2,
      ),
      itemCount: sortedOrders.length,
      itemBuilder: (context, index) {
        final order = sortedOrders[index];
        return ActiveOrderTile(
          order: order,
          onTap: onOrderTilePressed != null
              ? () => onOrderTilePressed!(order)
              : null,
        );
      },
    );
  }
}

class ActiveOrderTile extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onTap;

  const ActiveOrderTile({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: AppDecorations.gridTileDecoration(context),
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(
            //   "Order No.",
            //   style: TextStyle(
            //     fontSize: 8.sp,
            //     color: AppColors.accent,
            //   ),
            // ),
            Text(
              "${order['OrderNum']}",
              style: TextStyle(
                fontSize: 20.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "${order['Amount']} Rs.",
              style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold
              ),
            ),
            if (onTap != null) ...[
              SizedBox(height: 4.h),
              Icon(
                Icons.touch_app,
                size: 6.sp,
                color: AppColors.white.withOpacity(0.6),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
