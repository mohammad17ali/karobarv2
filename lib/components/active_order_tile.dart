// active_order_tile.dart
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'order_details_card.dart';

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
            const Text(
              "Order No.",
              style: TextStyle(
                fontSize: 8,
                color: AppColors.accent,
              ),
            ),
            Text(
              "${order['OrderNum']}",
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${order['Amount']} Rs.",
              style: const TextStyle(
                fontSize: 10,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}