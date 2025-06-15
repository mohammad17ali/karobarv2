import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/constants.dart';
import 'active_orders_grid.dart';

class ActiveOrdersSection extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> activeOrders;
  final bool isOrderSelected;
  final Map<String, dynamic>? selectedOrder;
  final Function(Map<String, dynamic>) onOrderTilePressed;
  final VoidCallback onBackToOrders;
  final VoidCallback onCheckOrder;
  final VoidCallback onCancelOrder;
  final Function(Map<String, dynamic>) onPayOrder; // MODIFICATION: Added onPayOrder

  const ActiveOrdersSection({
    super.key,
    required this.isLoading,
    required this.activeOrders,
    required this.isOrderSelected,
    required this.selectedOrder,
    required this.onOrderTilePressed,
    required this.onBackToOrders,
    required this.onCheckOrder,
    required this.onCancelOrder,
    required this.onPayOrder, // MODIFICATION: Required onPayOrder in constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: AppDecorations.sidebarContainer(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          // SizedBox(height: 10.h), // No change
          SizedBox(
            height: (MediaQuery.of(context).size.height * 0.22).h,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : isOrderSelected
                ? _buildOrderDetailsView(context)
                : _buildOrdersGridView(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // No change
    return Row(
      children: [
        if (isOrderSelected)
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.white,
              size: 20.sp,
            ),
            onPressed: onBackToOrders,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        if (isOrderSelected) SizedBox(width: 6.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOrderSelected ? "Order Details" : "Active Orders",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              if (isOrderSelected)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.green, width: 1.w),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersGridView() {
    // No change
    return ActiveOrdersGrid(
      activeOrders: activeOrders,
      onOrderTilePressed: onOrderTilePressed,
    );
  }

  Widget _buildOrderDetailsView(BuildContext context) {
    if (selectedOrder == null) {
      return const Center(
        child: Text(
          'No order selected',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Order Info
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Order Number',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '${selectedOrder!['OrderNum']}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '${selectedOrder!['Amount']} Rs.',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 6.h),

          // Scrollable Section
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Items:',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                        Text(
                          '${selectedOrder!['ItemNames']}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // You can add more dynamic widgets here if needed
                ],
              ),
            ),
          ),
          SizedBox(height: 5.sp,),

          // Bottom Buttons
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Check',
                    AppColors.primary,
                    Icons.check_circle_outline,
                    onCheckOrder,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildActionButton(
                    'Cancel',
                    Colors.red,
                    Icons.cancel_outlined,
                    onCancelOrder,
                  ),
                ),
                SizedBox(width: 12.w), // MODIFICATION: Added spacing for the new button
                Expanded( // MODIFICATION: Added Pay button
                  child: _buildActionButton(
                    'Pay',
                    Colors.green, // You can choose a suitable color
                    Icons.payment,
                        () => onPayOrder(selectedOrder!), // Pass selectedOrder to onPayOrder
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String text,
      Color color,
      IconData icon,
      VoidCallback onPressed,
      ) {
    // No change
    return SizedBox(
      width: 80.w,
      height: 32.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 12.sp),
        label: Text(
          text,
          style: TextStyle(fontSize: 10.sp),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
      ),
    );
  }
}