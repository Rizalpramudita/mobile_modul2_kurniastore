import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';

class ProductControllerDio extends GetxController {
  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final responseTimeMs = 0.0.obs;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://fakestoreapi.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<void> fetchProducts() async {
    final stopwatch = Stopwatch()..start();
    isLoading.value = true;
    errorMessage.value = '';

    // 🔹 Mulai event untuk DevTools
    developer.Timeline.startSync('DIO Fetch Products');

    try {
      final response = await _dio.get('/products');
      final List data = response.data;

      products.value =
          data.map((e) => ProductModel.fromJson(e)).toList();
    } on DioException catch (e) {
      errorMessage.value = e.message ?? 'Dio Error';
    } catch (e) {
      errorMessage.value = 'Unexpected Error: $e';
    } finally {
      stopwatch.stop();
      responseTimeMs.value = stopwatch.elapsedMilliseconds.toDouble();
      isLoading.value = false;

      // 🔹 Catatan waktu untuk log DevTools
      developer.log('DIO Response Time: ${responseTimeMs.value} ms',
          name: 'DIO');
      developer.Timeline.finishSync();
    }
  }
}
