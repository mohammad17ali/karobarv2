//sidebar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/postOrder.dart';
import '../components/active_orders_section.dart';
import '../components/order_details_section.dart';
import '../constants/constants.dart';
import '../screens/menus.dart';
import '../screens/dashboard.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Sidebar extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onOrderSuccess;
  final List<Map<String, dynamic>> orders;
  final bool isOrdersLoading;
  final VoidCallback onRefreshOrders;
  final Function(Map<String, dynamic>) onCancelOrder;
  final Function(Map<String, dynamic>) onPayOrder;

  const Sidebar({
    super.key,
    required this.cartItems,
    required this.onOrderSuccess,
    required this.orders,
    required this.isOrdersLoading,
    required this.onRefreshOrders,
    required this.onCancelOrder,
    required this.onPayOrder,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isOrderSelected = false;
  Map<String, dynamic>? _selectedOrder;
  bool _isProcessingOrder = false; 

  @override
  void initState() {
    super.initState();
  }

  Future<void> _postOrder() async {
    setState(() {
      _isProcessingOrder = true;
    });

    try {
      await OrderService.postOrders(
        widget.cartItems,
        "user9123456789",
        "out9987654321",
        _nextOrderNumber,
      );
      widget.onOrderSuccess();
      widget.onRefreshOrders(); 

      setState(() {
        _isProcessingOrder = false; 
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to place order. Please try again.'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int get _nextOrderNumber => (widget.orders.isNotEmpty ? widget.orders.last['OrderNum'] as int : 0) + 1;

  List<Map<String, dynamic>> get _activeOrders =>
      widget.orders.where((order) => order['Status'] == 'Active').map((order) {
        return {
          'OrderNum': order['OrderNum'],
          'Amount': order['Amount'],
          'ItemNames': order['ItemNames'] is List
              ? (order['ItemNames'] as List).join(', ')
              : order['ItemNames'].toString(),
        };
      }).toList();

  void _onOrderTilePressed(Map<String, dynamic> order) {
    setState(() {
      _isOrderSelected = true;
      _selectedOrder = order;
    });
  }

  void _onBackToOrders() {
    setState(() {
      _isOrderSelected = false;
      _selectedOrder = null;
    });
  }

  void _onCheckOrder() {
    if (_selectedOrder != null) {
      print('Check order: ${_selectedOrder?['OrderNum']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checking order ${_selectedOrder?['OrderNum']}...'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _onCancelOrder() {
    if (_selectedOrder != null) {
      final fullOrder = widget.orders.firstWhere(
            (order) => order['OrderNum'] == _selectedOrder!['OrderNum'],
        orElse: () => _selectedOrder!,
      );

      widget.onCancelOrder(fullOrder);
      _onBackToOrders();
    }
  }

  void _onPayOrder(Map<String, dynamic> orderToPay) {
    widget.onPayOrder(orderToPay);
    _onBackToOrders(); 
  }


  String selectedValue = 'Monday Menu';
  final List<String> dropdownItems = ["Monday Menu", "Tuesday Menu", "Wednesday Menu"];

  void onButtonPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Selected: $selectedValue")),
    );
  }

  Widget _buildOrderProcessingSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 60.w,
          height: 60.h,
          child: CircularProgressIndicator(
            strokeWidth: 4.w,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          'Processing Order...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Please wait while we confirm your order',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      decoration: const BoxDecoration(
        color: Color(0xFF4527A0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(2, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 5.h),
          ActiveOrdersSection(
            isLoading: widget.isOrdersLoading, 
            activeOrders: _activeOrders,
            isOrderSelected: _isOrderSelected,
            selectedOrder: _selectedOrder,
            onOrderTilePressed: _onOrderTilePressed,
            onBackToOrders: _onBackToOrders,
            onCheckOrder: _onCheckOrder,
            onCancelOrder: _onCancelOrder,
            onPayOrder: _onPayOrder, 
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: _isProcessingOrder
                ? _buildOrderProcessingSection() 
                : widget.cartItems.isEmpty
                ? _buildManageSection(context) 
                : OrderDetailsSection( 
              cartItems: widget.cartItems,
              nextOrderNumber: _nextOrderNumber,
              onConfirm: _postOrder,
              onPay: () {}, 
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageSection(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 5.h),
      Container(
        padding: const EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height * 0.2,
        decoration: BoxDecoration(
          color: Colors.deepPurple[700],
          borderRadius: BorderRadius.circular(12.h),
          border: Border.all(color: AppColors.primaryLight, width: 1.h),
          image: const DecorationImage(
            image: AssetImage('lib/assets/contB.png'),
            fit: BoxFit.cover,
            alignment: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Menu", style: AppTextStyles.titleMedium(context)),
            SizedBox(height: 10.h),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 40.h,
                    child: DropdownButtonFormField<String>(
                      value: selectedValue,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.h),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: dropdownItems.map((String item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 14.sp,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value!;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                SizedBox(
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed: onButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.h),
                      ),
                    ),
                    child: Text("Submit", style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      SizedBox(height: 12.h),
      SizedBox(
        width: double.infinity,
        height: 40.h,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MenuManagementPage(),
              ),
            );
          },
          icon: const Icon(Icons.menu_book),
          label: const Text('Manage Menus'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.h),
            ),
          ),
        ),
      ),
      SizedBox(height: 12.h),
      SizedBox(
        width: double.infinity,
        height: 40.h,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardPage(),
              ),
            );
          },
          icon: const Icon(Icons.arrow_circle_left_outlined),
          label: const Text('Go to Dashboard'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.h),
            ),
          ),
        ),
      ),
    ],
  );
}
