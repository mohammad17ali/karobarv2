// order_details_card.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/constants.dart';

class OrderDetailsCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blurred background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.transparent,
            ),
          ),
          // Content
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.60, // Reduced width
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Close button
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView( // Changed from Column to ListView to allow scrolling for items
                     children: [
                        const Text(
                          'Order Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
 _buildDetailRow('Order Number:', '${order['OrderNum']}'),
                        _buildDetailRow('Amount:', '${order['Amount']} Rs.'),
                        const SizedBox(height: 16),
                        const Text(
                          'Items:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Display cart items
                        if (order['cartItems'] != null)
                          ...List.generate(
                            order['cartItems'].length,
                                (index) {
                              final item = order['cartItems'][index];
                              return _buildItemRow(
                                  item['name'], item['quantity'], item['price']);
                            },
                          ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton(
                              'Check',
                              AppColors.primary,
                                  () => Navigator.pop(context),
                            ),
                            _buildButton(
                              'Cancel',
                              Colors.red,
                                  () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String name, int quantity, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$quantity x $name',
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          Text(
            '${(quantity * price).toStringAsFixed(2)} Rs.',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 100, // Fixed width for buttons
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14,
          color: Colors.white,),

        ),
      ),
    );
  }
}
