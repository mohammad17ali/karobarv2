import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../lib/screens/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const RestaurantHomePage());
  });
}

