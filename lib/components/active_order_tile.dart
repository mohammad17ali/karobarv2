import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'order_details_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ActiveOrderTile extends StatelessWidget {
  final Map<String, dynamic> order;

  const ActiveOrderTile({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsCard(order: order),
          ),
        );
      },
      child: Container(
        decoration: AppDecorations.gridTileDecoration(context),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Order No.",
              style: TextStyle(
                fontSize: 8.sp,
                color: AppColors.accent,
              ),
            ),
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
                fontSize: 10.sp,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
