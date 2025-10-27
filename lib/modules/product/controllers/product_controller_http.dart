import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductControllerHttp extends GetxController {
  final String apiUrl = "https://fakestoreapi.com/products";
  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final responseTimeMs = 0.obs; // in milliseconds

  /// Memuat data dan mengisi products observable
  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final sw = Stopwatch()..start();
      final resp = await http.get(Uri.parse(apiUrl));
      sw.stop();
      responseTimeMs.value = sw.elapsedMilliseconds;

      if (resp.statusCode == 200) {
        final List data = json.decode(resp.body);
        final list = data.map((e) => ProductModel.fromJson(e)).toList();
        products.value = list;
      } else {
        errorMessage.value = 'HTTP Error: ${resp.statusCode}';
        products.clear();
      }
    } catch (e) {
      errorMessage.value = 'HTTP Exception: $e';
      products.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
