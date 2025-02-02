// lib/sidebar.dart
import 'package:flutter/material.dart';
import '../services/fetchOrders.dart';
import '../services/postOrder.dart';
import '../components/active_orders_grid.dart';
import '../components/order_details_section.dart';
import '../constants/constants.dart';
import '../screens/menus.dart';
import '../screens/dashboard.dart';

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
      _orders.where((order) => order['Status'] == 'Active').toList();
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
          const SizedBox(height: 16),
          _buildActiveOrdersSection(context),
          const SizedBox(height: 15),
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

  Widget _buildLogo() => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Image.asset(
      'lib/assets/logoR.png',
      height: 30,
      fit: BoxFit.contain,
    ),
  );
  //Widget _buildManageButton() =>

  Widget _buildManageSection(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.2,
        decoration: BoxDecoration(
          color: Colors.deepPurple[700],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryLight, width: 1),
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
            Text("Menu", style: AppTextStyles.titleLarge(context)),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 48,
                    child: DropdownButtonFormField<String>(
                      value: selectedValue,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: dropdownItems.map((String item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(color: Colors.deepPurple),
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
                const SizedBox(width: 8),
                // Action Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Submit", style: TextStyle(fontSize: 14,color: Colors.white)),
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        height: 48,
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
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardPage(),
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
              borderRadius: BorderRadius.circular(8),
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
        Text("Active Orders", style: AppTextStyles.titleLarge(context)),
        const SizedBox(height: 12),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ActiveOrdersGrid(activeOrders: _activeOrders),
        ),
      ],
    ),
  );
}