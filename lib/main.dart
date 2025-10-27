import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'modules/product/views/product_performance_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KurniaStoreApp());
}

class KurniaStoreApp extends StatelessWidget {
  const KurniaStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KurniaStore - Eksperimen API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.pinkAccent,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
        ),
      ),
      home: const ProductPerformanceView(),
    );
  }
}
