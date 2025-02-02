import 'package:flutter/material.dart';
import '../constants/constants.dart';

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
              style: AppTextStyles.bodyText(context),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              "${item['quantity']} x ${item['price']}",
              style: AppTextStyles.bodyText(context),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              "${(item['quantity'] as int) * (item['price'] as int)} Rs.",
              style: AppTextStyles.priceText(context),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}