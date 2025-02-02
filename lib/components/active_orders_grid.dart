// lib/components/active_orders_grid.dart
import 'package:flutter/material.dart';
import 'active_order_tile.dart';

class ActiveOrdersGrid extends StatelessWidget {
  final List<Map<String, dynamic>> activeOrders;

  const ActiveOrdersGrid({
    super.key,
    required this.activeOrders,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        //final crossAxisCount = (constraints.maxWidth ~/ 150).clamp(2, 4);
        return GridView.builder(
          shrinkWrap: true,
          //physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 5/4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: activeOrders.length,
          itemBuilder: (context, index) => ActiveOrderTile(
            order: activeOrders[index],
          ),
        );
      },
    );
  }
}