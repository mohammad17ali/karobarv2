import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/fetchItems.dart';
import '../components/sidebar.dart';
import '../constants/constants.dart';
import 'dashboard.dart';
import 'menus.dart';

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
  int _toggleIndex = 0;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    _searchController.addListener(_onSearchChanged);
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

  // Determine layout based on device and orientation
  bool get _useLandscapeLayout {
    return widget.isLandscape && (widget.isTablet || MediaQuery.of(context).size.width > 600);
  }

  void _navigateToCart() {
    // Navigate to a dedicated cart page in portrait mode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          cartItems: _cartItems,
          onOrderSuccess: () {
            setState(() {
              _cart.clear();
              _cartItems.clear();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _useLandscapeLayout
          ? _buildLandscapeLayout()
          : _buildPortraitLayout(),
      floatingActionButton: !_useLandscapeLayout && _cartItems.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _navigateToCart,
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.shopping_cart, color: Colors.white),
        label: Text(
          'Cart (${_cartItems.fold(0, (sum, item) => sum + item['quantity'] as int)})',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
          : null,
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Sidebar(
          cartItems: _cartItems,
          onOrderSuccess: () {
            setState(() {
              _cart.clear();
              _cartItems.clear();
            });
          },
        ),
        Expanded(child: _buildMainContent()),
      ],
    );
  }

  Widget _buildPortraitLayout() {
    return _buildMainContent();
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    if (_useLandscapeLayout) {
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search menu...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
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
            child: Image.asset(
              'lib/assets/logoR.png',
              height: 40,
            ),
          ),
        ],
      );
    } else {
      // Portrait AppBar - More compact
      return AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Golden Rice, Casa Bella",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              height: 32.h,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'Search menu...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        toolbarHeight: 85.h,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Image.asset(
              'lib/assets/logoR.png',
              height: 25.h,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildMainContent() => Column(
    children: [
      _buildCategoryBar(),
      Expanded(
        child: Padding(
          padding: EdgeInsets.all(_useLandscapeLayout ? 16.0 : 6.0),
          child: _buildItemsGrid(),
        ),
      ),
    ],
  );

  Widget _buildCategoryBar() => Container(
    height: _useLandscapeLayout ? 50.h : 55.h,
    color: AppColors.primary,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: _useLandscapeLayout ? 8.w : 6.w),
      children: _categories.map(_buildCategoryButton).toList(),
    ),
  );

  Widget _buildCategoryButton(String title) => Padding(
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
          color: _selectedCategory == title ? Colors.white : AppColors.catNotSelectedTXT,
          fontSize: _useLandscapeLayout ? 14.sp : 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  Widget _buildItemsGrid() => GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: _useLandscapeLayout ? 4 : 3, // Changed to 3 for portrait
      childAspectRatio: _useLandscapeLayout ? 0.85 : 0.8, // Adjusted aspect ratio
      crossAxisSpacing: _useLandscapeLayout ? 16 : 4, // Reduced spacing
      mainAxisSpacing: _useLandscapeLayout ? 16 : 4, // Reduced spacing
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

  Widget _buildItemCard(Map<String, dynamic> item, bool isAdded, int quantity) => Stack(
    children: [
      Card(
        margin: EdgeInsets.all(_useLandscapeLayout ? 4.0 : 1.0), // Reduced margin for portrait
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_useLandscapeLayout ? 16 : 12), // Smaller radius for portrait
        ),
        elevation: _useLandscapeLayout ? 4 : 2, // Reduced elevation for portrait
        color: isAdded ? AppColors.accent : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: _useLandscapeLayout ? 3 : 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_useLandscapeLayout ? 16 : 12)
                  ),
                  image: DecorationImage(
                    image: NetworkImage(item['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: _useLandscapeLayout ? 1 : 2, // More space for text in portrait
              child: Padding(
                padding: EdgeInsets.all(_useLandscapeLayout ? 8.0 : 4.0), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Text(
                        item['name'],
                        style: TextStyle(
                          color: isAdded ? Colors.white : AppColors.primaryDark,
                          fontSize: _useLandscapeLayout ? 14.sp : 9.sp, // Smaller font for portrait
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
                        fontSize: _useLandscapeLayout ? 14.sp : 9.sp, // Smaller font for portrait
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
            radius: _useLandscapeLayout ? 20 : 12, // Smaller for portrait
            backgroundColor: AppColors.success,
            child: Text(
              quantity.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: _useLandscapeLayout ? 14.sp : 9.sp, // Smaller font
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
              radius: _useLandscapeLayout ? 24 : 16, // Smaller for portrait
              backgroundColor: Colors.white,
              child: Icon(
                quantity > 1 ? Icons.remove : Icons.delete,
                color: AppColors.accent,
                size: _useLandscapeLayout ? 20 : 14, // Smaller icon
              ),
            ),
          ),
        ),
      ],
    ],
  );
}

// New CartPage for portrait mode
class CartPage extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onOrderSuccess;

  const CartPage({
    super.key,
    required this.cartItems,
    required this.onOrderSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Sidebar(
        cartItems: cartItems,
        onOrderSuccess: () {
          onOrderSuccess();
          Navigator.pop(context);
        },
      ),
    );
  }
}
