//order_item_tile.dart

import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderItemTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const OrderItemTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item['name'],
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              "${item['quantity']} x ${item['price']}",
              style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              "${(item['quantity'] as int) * (item['price'] as int)} Rs.",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}