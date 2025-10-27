import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';

class ProductControllerDio extends GetxController {
  final Dio dio = Dio(BaseOptions(baseUrl: "https://fakestoreapi.com"));
  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final responseTimeMs = 0.obs;

  ProductControllerDio() {
    // optional: add basic logging for debugging
    dio.interceptors.add(LogInterceptor(responseBody: false));
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final sw = Stopwatch()..start();
      final resp = await dio.get("/products");
      sw.stop();
      responseTimeMs.value = sw.elapsedMilliseconds;

      if (resp.statusCode == 200) {
        final data = resp.data as List;
        final list = data.map((e) => ProductModel.fromJson(e)).toList();
        products.value = list;
      } else {
        errorMessage.value = 'Dio Error: ${resp.statusCode}';
        products.clear();
      }
    } on DioException catch (e) {
      errorMessage.value = 'Dio Exception: ${e.message}';
      products.clear();
    } catch (e) {
      errorMessage.value = 'Unknown Dio Error: $e';
      products.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
