import 'dart:convert';
import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductControllerHttp extends GetxController {
  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final responseTimeMs = 0.0.obs;

  Future<void> fetchProducts() async {
    final stopwatch = Stopwatch()..start();
    isLoading.value = true;
    errorMessage.value = '';

    // 🔹 Mulai event untuk DevTools
    developer.Timeline.startSync('HTTP Fetch Products');

    try {
      final url = Uri.parse('https://fakestoreapi.com/products');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        products.value =
            data.map((e) => ProductModel.fromJson(e)).toList();
      } else {
        errorMessage.value = 'HTTP Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      stopwatch.stop();
      responseTimeMs.value = stopwatch.elapsedMilliseconds.toDouble();
      isLoading.value = false;

      // 🔹 Akhiri event dan beri catatan waktu
      developer.log('HTTP Response Time: ${responseTimeMs.value} ms',
          name: 'HTTP');
      developer.Timeline.finishSync();
    }
  }
}
