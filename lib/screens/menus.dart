import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/constants.dart';
import 'dashboard.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({Key? key}) : super(key: key);

  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage> {
  String selectedMenu = 'Monday Menu';
  bool isMenuProcessing = false;
  int processingMenuCount = 0;
  
  // Cloudinary configuration
  final String cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dadzja33r/image/upload';
  final String uploadPreset = 'ped8w8lo'; 
  final String apiKey = '231989115235679';
  final String apiSecret = 'gDTQWkuAEEGwBghFbnMrLX60zcI';

  final ImagePicker _picker = ImagePicker();

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
        title: Text('Golden Rice, Casa Bella', style: AppTextStyles.titleLarge(context)),
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
                _buildImageUploadButton(),
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
                
                // Processing status section
                if (isMenuProcessing || processingMenuCount > 0)
                  _buildProcessingStatus(),
                
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

  Widget _buildImageUploadButton() {
    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Container(
        padding: EdgeInsets.all(20.sp),
        margin: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(
          color: Colors.deepPurple[700],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryLight, width: 1),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.camera, color: AppColors.white),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Scan a menu',
                style: AppTextStyles.buttonText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Expanded(
              child: Text(text, style: AppTextStyles.buttonText(context)),
            ),
          ],
        ),
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

  Widget _buildProcessingStatus() {
    return Container(
      margin: EdgeInsets.all(8.sp),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16.w,
                height: 16.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Menu being processed',
                style: TextStyle(
                  color: Colors.orange[800],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (processingMenuCount > 0)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                'Count: $processingMenuCount',
                style: TextStyle(
                  color: Colors.orange[600],
                  fontSize: 11.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pick from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImages(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImages(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        // Pick multiple images from gallery
        final List<XFile> images = await _picker.pickMultipleMedia();
        if (images.isNotEmpty) {
          _uploadImagesToCloudinary(images);
        }
      } else {
        // Take a single photo with camera
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          _uploadImagesToCloudinary([image]);
        }
      }
    } catch (e) {
      _showErrorDialog('Error picking images: $e');
    }
  }

  Future<void> _uploadImagesToCloudinary(List<XFile> images) async {
    setState(() {
      isMenuProcessing = true;
      processingMenuCount++;
    });

    List<String> uploadedUrls = [];

    try {
      for (XFile image in images) {
        String? url = await _uploadSingleImage(image);
        if (url != null) {
          uploadedUrls.add(url);
        }
      }

      // Simulate processing delay
      await Future.delayed(Duration(seconds: 3));

      _showSuccessDialog('Successfully uploaded ${uploadedUrls.length} images!');
      
    } catch (e) {
      _showErrorDialog('Upload failed: $e');
    } finally {
      setState(() {
        isMenuProcessing = false;
      });
    }
  }

  Future<String?> _uploadSingleImage(XFile image) async {
    try {
      // Convert image to base64
      File file = File(image.path);
      List<int> imageBytes = await file.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      
      // Prepare the request
      var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      
      // Add form fields
      request.fields['file'] = 'data:image/jpeg;base64,$base64Image';
      request.fields['upload_preset'] = uploadPreset;
      request.fields['api_key'] = apiKey;
      
      // Generate signature (simplified - in production, do this server-side)
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      request.fields['timestamp'] = timestamp;
      
      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        return jsonResponse['secure_url'];
      } else {
        print('Upload failed: ${response.statusCode}');
        print('Response: $responseData');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(Icons.error, color: Colors.red, size: 48),
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}