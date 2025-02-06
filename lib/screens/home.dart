import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/fetchItems.dart';
import '../components/sidebar.dart';
import '../constants/constants.dart';
//import 'ledger.dart';
import 'dashboard.dart';
import 'menus.dart';


class RestaurantHomePage extends StatelessWidget {
  const RestaurantHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'karobar',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

  static const List<String> _categories = [
    "All",
    "Starters",
    "Main Course",
    "Chinese",
    "Indian",
    "Continental"
  ];

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
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

  List<Map<String, dynamic>> get _filteredItems => _selectedCategory == 'All'
      ? _foodItems
      : _foodItems.where((item) => item['category'].contains(_selectedCategory)).toList();

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    title: Text(
      "The Zaika Restaurant",
      style: AppTextStyles.titleLarge(context).copyWith(color: Colors.white),
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

  Widget _buildMainContent() => Column(
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

  Widget _buildCategoryBar() => Container(
    height: 50,
    color: AppColors.primary,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: _categories.map(_buildCategoryButton).toList(),
    ),
  );

  Widget _buildCategoryButton(String title) => Padding(
    padding: const EdgeInsets.all(4),
    child: ElevatedButton(
      onPressed: () => setState(() => _selectedCategory = title),
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedCategory == title
            ? AppColors.accent
            : AppColors.catNotSelectedBG,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: _selectedCategory == title ? Colors.white : AppColors.catNotSelectedTXT,
        ),
      ),
    ),
  );

  Widget _buildItemsGrid() => GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      childAspectRatio: 0.85,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
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
        margin: const EdgeInsets.fromLTRB(2, 10, 10, 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        color: isAdded ? AppColors.accent : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: NetworkImage(item['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: TextStyle(
                      color: isAdded ? Colors.white : AppColors.primaryDark,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${item['price']} Rs.",
                    style: TextStyle(
                      color: isAdded ? Colors.white : Colors.green,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (isAdded) ...[
        Positioned(
          right: 0,
          top: 0,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.success,
            child: Text(
              quantity.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: GestureDetector(
            onTap: () => _handleItemRemove(item['itemID'], quantity),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Icon(
                quantity > 1 ? Icons.remove : Icons.delete,
                color: AppColors.accent,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    ],
  );
}