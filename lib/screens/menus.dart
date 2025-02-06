import 'package:flutter/material.dart';
import  'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/constants.dart';
import 'dashboard.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({Key? key}) : super(key: key);

  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage> {
  String selectedMenu = 'Monday Menu';

  // Sample menu data
  final List<String> menus = [
    'Monday Menu',
    'Tuesday Menu',
    'Wednesday Menu',
    'Thursday Menu',
    'Friday Menu',
  ];

  // Sample category and items data
  final Map<String, List<String>> menuItems = {
    'Starters': ['Paneer Tikka', 'Veg Spring Roll', 'Mushroom Manchurian'],
    'Main Course': ['Dal Makhani', 'Paneer Butter Masala', 'Veg Biryani'],
    'Desserts': ['Gulab Jamun', 'Ice Cream', 'Rasmalai'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('The Zaika Restaurant', style: AppTextStyles.titleLarge(context)),
        elevation: 0,
      ),
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              border: Border(
                right: BorderSide(
                  color: AppColors.grey,
                ),
              ),
            ),
            child: Column(
              children: [
                _buildSidebarButton(
                  'Scan a menu',
                  LucideIcons.qrCode,
                      () => Navigator.pushNamed(context, 'AddMenuScan'),
                ),
                _buildSidebarButton(
                  'Add a menu',
                  LucideIcons.plus,
                      () => Navigator.pushNamed(context, 'AddMenuManual'),
                ),
                Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: Divider(),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: menus.length,
                    itemBuilder: (context, index) {
                      return _buildMenuButton(menus[index]);
                    },
                  ),
                ),
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48.h,
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
                        padding: EdgeInsets.symmetric(horizontal: 20.sp),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.sp),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: AppShadows.cardShadow,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedMenu,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(LucideIcons.pencil, color: Colors.white),
                          label: const Text('Edit Menu'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.sp,
                              vertical: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu items grouped by category
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.sp),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        String category = menuItems.keys.elementAt(index);
                        List<String> items = menuItems[category]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.sp),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, itemIndex) {
                                return Container(
                                  decoration: AppDecorations.gridTileDecoration(context),
                                  padding: EdgeInsets.all(16.sp),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        items[itemIndex],
                                        style: TextStyle(
                                          color: Colors.deepPurple,
                                          fontSize: 14.sp,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        '₹299',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 24.h),
                          ],
                        );
                      },
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

  Widget _buildSidebarButton(String text, IconData icon, VoidCallback onTap) {
    return Container(
      padding: EdgeInsets.all(20.sp),
      margin: EdgeInsets.all(8.sp),
      decoration: BoxDecoration(
        color: Colors.deepPurple[700],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.white),
          SizedBox(width: 12.w),
          Text(text, style: AppTextStyles.buttonText(context)),
        ],
      ),

    );
  }

  Widget _buildMenuButton(String menuName) {
    bool isSelected = selectedMenu == menuName;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Material(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedMenu = menuName;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              menuName,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.primaryDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
