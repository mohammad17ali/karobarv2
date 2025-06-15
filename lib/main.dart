import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home.dart';
import 'dart:math';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Allow all orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const KarobarApp());
  });
}

class KarobarApp extends StatelessWidget {
  const KarobarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Default design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'karobar',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          home: const ResponsiveHomePage(),
        );
      },
    );
  }
}

class ResponsiveHomePage extends StatelessWidget {
  const ResponsiveHomePage({Key? key}) : super(key: key);

  bool _isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonalInches = sqrt(size.width * size.width + size.height * size.height) /
        MediaQuery.of(context).devicePixelRatio;
    return diagonalInches >= 7.0 || size.shortestSide >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isTablet = _isTablet(context);

    // Optionally update ScreenUtil design size based on context
    final designSize = isLandscape
        ? (isTablet ? const Size(1300, 600) : const Size(800, 360))
        : const Size(360, 690);

    ScreenUtil.init(
      context,
      designSize: designSize,
    );

    return HomePage(
      isTablet: isTablet,
      isLandscape: isLandscape,
    );
  }
}
