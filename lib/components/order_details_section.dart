// lib/components/order_details_section.dart
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'order_item_tile.dart';

class OrderDetailsSection extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final int nextOrderNumber;
  final VoidCallback onConfirm;
  final VoidCallback onPay;

  const OrderDetailsSection({
    super.key,
    required this.cartItems,
    required this.nextOrderNumber,
    required this.onConfirm,
    required this.onPay,
  });

  int get totalAmount => cartItems.fold<int>(
    0,
        (sum, item) => sum + ((item['quantity'] as num).toInt() * (item['price'] as num).toInt()),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.sidebarContainer(context),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          _buildOrderList(context),
          const Divider(color: Colors.white70),
          _buildTotalSection(context),
          const SizedBox(height: 12),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("Order Details", style: AppTextStyles.titleMedium(context)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "#$nextOrderNumber",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14 * MediaQuery.textScaleFactorOf(context),
          ),
        ),
      ),
    ],
  );

  Widget _buildOrderList(BuildContext context) => Expanded(
    child: ListView.separated(
      itemCount: cartItems.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white24),
      itemBuilder: (context, index) => OrderItemTile(
        item: cartItems[index],
      ),
    ),
  );

  Widget _buildTotalSection(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Total:", style: AppTextStyles.titleLarge(context)),
        Text(
          "$totalAmount Rs.",
          style: AppTextStyles.priceText(context),
        ),
      ],
    ),
  );

  Widget _buildActionButtons(BuildContext context) => Row(
    children: [
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: onConfirm,
          child: const Text(
            "Confirm",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: onPay,
          child: const Text(
            "Pay Now",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ],
  );
}