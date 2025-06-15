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
  // New props for order management
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
  bool _isProcessingOrder = false; // State for order processing

  @override
  void initState() {
    super.initState();
  }

  Future<void> _postOrder() async {
    setState(() {
      _isProcessingOrder = true; // Show loading state
    });

    try {
      await OrderService.postOrders(
        widget.cartItems,
        "user9123456789",
        "out9987654321",
        _nextOrderNumber,
      );
      widget.onOrderSuccess();
      widget.onRefreshOrders(); // Refresh orders from parent

      setState(() {
        _isProcessingOrder = false; // Hide loading state
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
        _isProcessingOrder = false; // Hide loading state on error
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

  // Use orders from props instead of local state
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
      // Find the full order data from widget.orders
      final fullOrder = widget.orders.firstWhere(
            (order) => order['OrderNum'] == _selectedOrder!['OrderNum'],
        orElse: () => _selectedOrder!,
      );

      widget.onCancelOrder(fullOrder);
      _onBackToOrders(); // Go back to orders list after cancelling
    }
  }

  void _onPayOrder() {
    if (_selectedOrder != null) {
      // Find the full order data from widget.orders
      final fullOrder = widget.orders.firstWhere(
            (order) => order['OrderNum'] == _selectedOrder!['OrderNum'],
        orElse: () => _selectedOrder!,
      );

      widget.onPayOrder(fullOrder);
      _onBackToOrders(); // Go back to orders list after payment
    }
  }

  String selectedValue = 'Monday Menu';
  final List<String> dropdownItems = ["Monday Menu", "Tuesday Menu", "Wednesday Menu"];

  void onButtonPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Selected: $selectedValue")),
    );
  }

  // Loading widget for order processing
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
            isLoading: widget.isOrdersLoading, // Use prop instead of local state
            activeOrders: _activeOrders,
            isOrderSelected: _isOrderSelected,
            selectedOrder: _selectedOrder,
            onOrderTilePressed: _onOrderTilePressed,
            onBackToOrders: _onBackToOrders,
            onCheckOrder: _onCheckOrder,
            onCancelOrder: _onCancelOrder,
            // onPayOrder: _onPayOrder, // Add pay order callback
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: _isProcessingOrder
                ? _buildOrderProcessingSection() // Show loading when processing order
                : widget.cartItems.isEmpty
                ? _buildManageSection(context) // Show manage section when cart is empty
                : OrderDetailsSection( // Show order details when cart has items
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

---

//home.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/fetchItems.dart';
import '../services/fetchOrders.dart'; // ADD THIS IMPORT
import '../services/postOrder.dart';
import '../components/sidebar.dart';
import '../constants/constants.dart';

class HomePage extends StatefulWidget {
  final bool isTablet;
  final bool isLandscape;

  const HomePage({
    super.key,
    required this.isTablet,
    required this.isLandscape,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Dynamic orientation setting - can be changed to force specific layout
  static const bool FORCE_LANDSCAPE = false; // Set to true to force landscape layout
  static const bool FORCE_PORTRAIT = false;  // Set to true to force portrait layout

  final Map<String, int> _cart = {};
  final List<Map<String, dynamic>> _cartItems = [];
  String _selectedCategory = 'All';
  List<Map<String, dynamic>> _foodItems = [];
  bool _isLoading = true;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // REPLACE PLACEHOLDER WITH REAL ORDER MANAGEMENT
  List<Map<String, dynamic>> _orders = [];
  bool _isOrdersLoading = true;
  bool _isProcessingOrder = false;

  // Order details overlay
  Map<String, dynamic>? _selectedOrder;

  static const List<String> _categories = [
    "All",
    "Egg Rice",
    "Non Veg Noodles",
    "Egg Starter",
    "Veg Main Course",
    "Non Veg Main Course",
    "Beverages",
    "Extras",
    "Biryani"
  ];

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
    _loadOrders();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await FetchOrders.fetchOrders();
      setState(() {
        _orders = orders;
        _isOrdersLoading = false;
      });
    } catch (e) {
      setState(() => _isOrdersLoading = false);
    }
  }

  Future<void> _postOrder() async {
    setState(() {
      _isProcessingOrder = true;
    });

    try {
      await OrderService.postOrders(
        _cartItems,
        "user9123456789",
        "out9987654321",
        _nextOrderNumber,
      );

      setState(() {
        _cart.clear();
        _cartItems.clear();
        _isProcessingOrder = false;
      });

      await _loadOrders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
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
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int get _nextOrderNumber => (_orders.isNotEmpty ? _orders.last['OrderNum'] as int : 0) + 1;

  List<Map<String, dynamic>> get _activeOrders =>
      _orders.where((order) => order['Status'] == 'Active').map((order) {
        return {
          'OrderNum': order['OrderNum'],
          'Amount': order['Amount'],
          'ItemNames': order['ItemNames'],
          'Status': order['Status'],
        };
      }).toList();

  void _handleCancelOrder(Map<String, dynamic> order) {
    // Implement cancel order logic
    print('Cancel order: ${order['OrderNum']}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${order['OrderNum']} cancelled'),
        backgroundColor: Colors.red,
      ),
    );
    _hideOrderDetails();
  }

  void _handlePayOrder(Map<String, dynamic> order) {
    // Implement payment logic
    print('Pay order: ${order['OrderNum']}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Processing payment for order ${order['OrderNum']}...'),
        backgroundColor: AppColors.primary,
      ),
    );
    _hideOrderDetails();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      if (_searchQuery.isNotEmpty) {
        _selectedCategory = 'All';
      }
    });
  }

  Future<void> _loadFoodItems() async {
    try {
      final items = await FetchItems.fetchFoodItems();
      setState(() {
        _foodItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredItems {
    List<Map<String, dynamic>> items;

    if (_selectedCategory == 'All') {
      items = _foodItems;
    } else {
      items = _foodItems.where((item) => item['category'].contains(_selectedCategory)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        final name = item['name'].toString().toLowerCase();
        final category = item['category'].toString().toLowerCase();
        return name.contains(_searchQuery) || category.contains(_searchQuery);
      }).toList();
    }

    return items;
  }

  void _handleItemTap(Map<String, dynamic> item) {
    final itemID = item['itemID'];
    setState(() {
      if (!_cart.containsKey(itemID)) {
        _cart[itemID] = 1;
        _cartItems.add({
          'itemID': itemID,
          'name': item['name'],
          'price': item['price'],
          'quantity': 1,
        });
      } else {
        _cart[itemID] = (_cart[itemID]! + 1);
        _cartItems.firstWhere((cartItem) => cartItem['itemID'] == itemID)['quantity']++;
      }
    });
  }

  void _handleItemRemove(String itemID, int quantity) {
    setState(() {
      if (quantity > 1) {
        _cart[itemID] = quantity - 1;
        _cartItems.firstWhere((cartItem) => cartItem['itemID'] == itemID)['quantity']--;
      } else {
        _cart.remove(itemID);
        _cartItems.removeWhere((cartItem) => cartItem['itemID'] == itemID);
      }
    });
  }

  // Determine layout based on dynamic settings and device orientation
  bool get _useLandscapeLayout {
    if (FORCE_LANDSCAPE) return true;
    if (FORCE_PORTRAIT) return false;
    return widget.isLandscape && (widget.isTablet || MediaQuery.of(context).size.width > 600);
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    setState(() {
      _selectedOrder = order;
    });
  }

  void _hideOrderDetails() {
    setState(() {
      _selectedOrder = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : _useLandscapeLayout
        ? _buildLandscapeScaffold()
        : _buildPortraitScaffold();
  }

  // LANDSCAPE LAYOUT
  Widget _buildLandscapeScaffold() {
    return Scaffold(
      appBar: _buildLandscapeAppBar(),
      body: Row(
        children: [
          Sidebar(
            cartItems: _cartItems,
            orders: _orders, // ADD THIS
            isOrdersLoading: _isOrdersLoading, // ADD THIS
            onOrderSuccess: () {
              setState(() {
                _cart.clear();
                _cartItems.clear();
              });
              _loadOrders(); // ADD THIS
            },
            onRefreshOrders: _loadOrders, // ADD THIS
          ),
          Expanded(child: _buildLandscapeMainContent()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildLandscapeAppBar() {
    return AppBar(
      title: Row(
        children: [
          Text(
            "Golden Rice, Casa Bella",
            style: AppTextStyles.titleLarge(context).copyWith(color: Colors.white),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Container(
              height: 40.h,
              constraints: BoxConstraints(maxWidth: 300.w),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Search menu...',
                  hintStyle: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  prefixIcon: Icon(Icons.search, color: Colors.white, size: 20.sp),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.primary,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Image.asset('lib/assets/logoR.png', height: 40),
        ),
      ],
    );
  }

  Widget _buildLandscapeMainContent() {
    return Column(
      children: [
        _buildCategoryBar(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildItemsGrid(),
          ),
        ),
      ],
    );
  }

  // PORTRAIT LAYOUT
  Widget _buildPortraitScaffold() {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildPortraitAppBar(),
              _buildPortraitSearchBar(),
              Expanded(child: _buildPortraitMainSection()),
              _buildPortraitActionSection(),
            ],
          ),
          if (_selectedOrder != null) _buildOrderDetailsOverlay(),
        ],
      ),
    );
  }

  Widget _buildPortraitAppBar() {
    return Container(
      height: 60.h,
      color: AppColors.primary,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Golden Rice, Casa Bella",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Image.asset('lib/assets/logoR.png', height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitSearchBar() {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: 'Search menu...',
            hintStyle: TextStyle(color: Colors.white70, fontSize: 14.sp),
            prefixIcon: Icon(Icons.search, color: Colors.white, size: 18.sp),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitMainSection() {
    return Column(
      children: [
        _buildCategoryBar(),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: _buildItemsGrid(),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitActionSection() {
    return Container(
      height: _cartItems.isEmpty ? 120.h : 180.h,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: _cartItems.isEmpty
          ? _buildActiveOrdersSection()
          : _buildCartDetailsSection(),
    );
  }

  Widget _buildActiveOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            'Active Orders',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        Expanded(
          child: _isOrdersLoading
              ? Center(child: CircularProgressIndicator())
              : _activeOrders.isEmpty
              ? Center(
            child: Text(
              'No active orders',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          )
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _activeOrders.length,
            itemBuilder: (context, index) {
              final order = _activeOrders[index];
              return GestureDetector(
                onTap: () => _showOrderDetails(order),
                child: Container(
                  width: 160.w,
                  margin: EdgeInsets.only(right: 12.w),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order['OrderNum']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${order['ItemNames'].length} items',
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: order['Status'] == 'Ready' ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              order['Status'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            '₹${order['Amount']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _buildCartDetailsSection() {
    final totalAmount = _cartItems.fold<double>(
        0, (sum, item) => sum + (item['price'] * item['quantity']));
    final totalItems = _cartItems.fold<int>(
        0, (sum, item) => sum + item['quantity'] as int);

    return Column(
      children: [
        Container(
          height: 120.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'Cart Summary',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 4.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['name'],
                              style: TextStyle(fontSize: 12.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${item['quantity']}x',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '₹${item['price'] * item['quantity']}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 60.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
          ),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalItems items',
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                  Text(
                    '₹$totalAmount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Spacer(),
              _isProcessingOrder
                  ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : ElevatedButton(
                onPressed: _postOrder, // CHANGE TO REAL METHOD
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: const Text(
                  'Place Order',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetailsOverlay() {
    final order = _selectedOrder!;
    return GestureDetector(
      onTap: _hideOrderDetails,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(32.w),
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _hideOrderDetails,
                      child: Icon(Icons.close, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                _buildOrderDetailRow('Order ID:', '#${order['OrderNum']}'),
                _buildOrderDetailRow('Status:', order['Status']),
                _buildOrderDetailRow('Total:', '₹${order['Amount']}'),
                SizedBox(height: 16.h),
                Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
                SizedBox(height: 8.h),
                ...order['ItemNames'].map<Widget>((item) => Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text('• $item', style: TextStyle(fontSize: 12.sp)),
                )),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleCancelOrder(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handlePayOrder(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text('Pay'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
          ),
          SizedBox(width: 8.w),
          Text(value, style: TextStyle(fontSize: 12.sp)),
        ],
      ),
    );
  }

  // SHARED COMPONENTS
  Widget _buildCategoryBar() {
    return Container(
      height: _useLandscapeLayout ? 50.h : 55.h,
      color: AppColors.primary,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: _useLandscapeLayout ? 8.w : 6.w),
        children: _categories.map(_buildCategoryButton).toList(),
      ),
    );
  }

  Widget _buildCategoryButton(String title) {
    return Padding(
      padding: EdgeInsets.all(_useLandscapeLayout ? 4.0 : 3.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedCategory = title;
            if (_searchQuery.isNotEmpty) {
              _searchController.clear();
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedCategory == title
              ? AppColors.accent
              : AppColors.catNotSelectedBG,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _useLandscapeLayout ? 16.w : 10.w,
            vertical: _useLandscapeLayout ? 8.h : 5.h,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _selectedCategory == title
                ? Colors.white
                : AppColors.catNotSelectedTXT,
            fontSize: _useLandscapeLayout ? 14.sp : 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildItemsGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _useLandscapeLayout ? 4 : 3,
        childAspectRatio: _useLandscapeLayout ? 0.85 : 0.8,
        crossAxisSpacing: _useLandscapeLayout ? 16 : 4,
        mainAxisSpacing: _useLandscapeLayout ? 16 : 4,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final itemID = item['itemID'];
        final isAdded = _cart.containsKey(itemID);
        final quantity = _cart[itemID] ?? 0;

        return GestureDetector(
          onTap: () => _handleItemTap(item),
          child: _buildItemCard(item, isAdded, quantity),
        );
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, bool isAdded, int quantity) {
    return Stack(
      children: [
        Card(
          margin: EdgeInsets.all(_useLandscapeLayout ? 4.0 : 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_useLandscapeLayout ? 16 : 12),
          ),
          elevation: _useLandscapeLayout ? 4 : 2,
          color: isAdded ? AppColors.accent : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: _useLandscapeLayout ? 3 : 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_useLandscapeLayout ? 16 : 12),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(item['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: _useLandscapeLayout ? 1 : 2,
                child: Padding(
                  padding: EdgeInsets.all(_useLandscapeLayout ? 8.0 : 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Text(
                          item['name'],
                          style: TextStyle(
                            color: isAdded ? Colors.white : AppColors.primaryDark,
                            fontSize: _useLandscapeLayout ? 14.sp : 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "${item['price']} Rs.",
                        style: TextStyle(
                          color: isAdded ? Colors.white : Colors.green,
                          fontSize: _useLandscapeLayout ? 14.sp : 9.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isAdded) ...[
          Positioned(
            right: 2,
            top: 2,
            child: CircleAvatar(
              radius: _useLandscapeLayout ? 20 : 12,
              backgroundColor: AppColors.success,
              child: Text(
                quantity.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _useLandscapeLayout ? 14.sp : 9.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            right: _useLandscapeLayout ? 10 : 4,
            bottom: _useLandscapeLayout ? 10 : 4,
            child: GestureDetector(
              onTap: () => _handleItemRemove(item['itemID'], quantity),
              child: CircleAvatar(
                radius: _useLandscapeLayout ? 24 : 16,
                backgroundColor: Colors.white,
                child: Icon(
                  quantity > 1 ? Icons.remove : Icons.delete,
                  color: AppColors.accent,
                  size: _useLandscapeLayout ? 20 : 14,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}