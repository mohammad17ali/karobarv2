import 'package:flutter/material.dart';
import '../services/fetchOrders.dart';
import '../services/postOrder.dart';
import '../components/active_orders_grid.dart';
import '../components/order_details_section.dart';
import '../constants/constants.dart';
import '../screens/menus.dart';
import '../screens/dashboard.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class Sidebar extends StatefulWidget {
  //final List<Map<String, dynamic>> ordersList;
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onOrderSuccess;

  const Sidebar({
    super.key,
    required this.cartItems,
    required this.onOrderSuccess,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  late List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await FetchOrders.fetchOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      //print('Error loading orders: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _postOrder() async {
    try {
      await OrderService.postOrders(
        widget.cartItems,
        "user9123456789",
        "out9987654321",
        _nextOrderNumber,
      );
      widget.onOrderSuccess();
      await _loadOrders();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to place order. Please try again.'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      //print('Error posting order: $e');
    }
  }
  int get _nextOrderNumber => (_orders.isNotEmpty ? _orders.last['OrderNum'] as int : 0) + 1;


  List<Map<String, dynamic>> get _activeOrders =>
      _orders.where((order) => order['Status'] == 'Active').map((order) {
        return {
          'OrderNum': order['OrderNum'],
          'Amount': order['Amount'],
          'ItemNames': order['ItemNames'].join(', '), // Display as comma-separated string
        };
      }).toList();

  String selectedValue = 'Monday Menu';
  final List<String> dropdownItems = ["Monday Menu", "Tuesday Menu", "Wednesday Menu"];
  void onButtonPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Selected: $selectedValue")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      decoration: const BoxDecoration(
        color: AppColors.primary,
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
          //_buildLogo(),
          SizedBox(
              height: 5.h
          ),
          _buildActiveOrdersSection(context),
          SizedBox(height: 10.h),
          Expanded(
            child: widget.cartItems.isEmpty
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
                              fontSize: 12.h,
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
                // Action Button
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
                    child: Text("Submit", style: TextStyle(fontSize: 14.sp,color: Colors.white)),
                  ),
                ),
              ],
            ),
            //const Spacer(),
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

  Widget _buildActiveOrdersSection(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: AppDecorations.sidebarContainer(context),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Active Orders", style: AppTextStyles.titleMedium(context)),
        SizedBox(height: 12.h),
        SizedBox(
          height: (MediaQuery.of(context).size.height * 0.22).h,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ActiveOrdersGrid(activeOrders: _activeOrders),
        ),
      ],
    ),
  );
}