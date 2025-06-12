//home.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/fetchItems.dart';
import '../services/fetchOrders.dart';
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
  final Map<String, int> _cart = {};
  final List<Map<String, dynamic>> _cartItems = [];
  String _selectedCategory = 'All';
  List<Map<String, dynamic>> _foodItems = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> _orders = [];
  bool _isOrdersLoading = true;
  bool _isProcessingOrder = false;

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
    print('Cancelling order: ${order['OrderNum']}');
    setState(() {
      _orders.removeWhere((o) => o['OrderNum'] == order['OrderNum']);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${order['OrderNum']} cancelled'),
        backgroundColor: Colors.red,
      ),
    );
    _hideOrderDetails();
    _loadOrders(); 
  }

  void _handlePayOrder(Map<String, dynamic> order) {
    print('Processing payment for order: ${order['OrderNum']}');
    setState(() {
      final index = _orders.indexWhere((o) => o['OrderNum'] == order['OrderNum']);
      if (index != -1) {
        _orders[index]['Status'] = 'Paid'; 
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Processing payment for order ${order['OrderNum']}...'),
        backgroundColor: AppColors.primary,
      ),
    );
    _hideOrderDetails();
    _loadOrders(); 
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

  bool get _useLandscapeLayout {
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

  Widget _buildLandscapeScaffold() {
    return Scaffold(
      appBar: _buildLandscapeAppBar(),
      body: Row(
        children: [
          Sidebar(
            cartItems: _cartItems,
            orders: _orders,
            isOrdersLoading: _isOrdersLoading,
            onOrderSuccess: () {
              setState(() {
                _cart.clear();
                _cartItems.clear();
              });
              _loadOrders();
            },
            onRefreshOrders: _loadOrders,
            onCancelOrder: _handleCancelOrder, 
            onPayOrder: _handlePayOrder, 
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
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : ElevatedButton.icon(
                onPressed: _cartItems.isEmpty ? null : _postOrder,
                icon: Icon(Icons.receipt_long, size: 20.sp),
                label: Text(
                  'Confirm Order',
                  style: TextStyle(fontSize: 14.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildOrderDetailsOverlay() {
    if (_selectedOrder == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20.w),
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Order Details #${_selectedOrder!['OrderNum']}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    'Amount: ₹${_selectedOrder!['Amount']}',
                    style: TextStyle(fontSize: 16.sp, color: Colors.green),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Status: ${_selectedOrder!['Status']}',
                    style: TextStyle(fontSize: 16.sp, color: Colors.blueGrey),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: _hideOrderDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                        ),
                        child: const Text('Close'),
                      ),
                      ElevatedButton(
                        onPressed: () => _handleCancelOrder(_selectedOrder!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cancel Order'),
                      ),
                      ElevatedButton(
                        onPressed: () => _handlePayOrder(_selectedOrder!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Pay Order'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
