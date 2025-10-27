import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller_http.dart';
import '../controllers/product_controller_dio.dart';
import '../models/product_model.dart';

class ProductPerformanceView extends StatefulWidget {
  const ProductPerformanceView({super.key});

  @override
  State<ProductPerformanceView> createState() => _ProductPerformanceViewState();
}

class _ProductPerformanceViewState extends State<ProductPerformanceView> {
  // controllers di-inject menggunakan GetX
  late final ProductControllerHttp httpController;
  late final ProductControllerDio dioController;

  bool httpLoaded = false;
  bool dioLoaded = false;

  double? httpDurationSec;
  double? dioDurationSec;

  @override
  void initState() {
    super.initState();
    httpController = Get.put(ProductControllerHttp());
    dioController = Get.put(ProductControllerDio());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eksperimen Performa HTTP vs Dio"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Tekan tombol untuk memuat data produk dari API. Hasil profiling akan muncul di tabel.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final sw = Stopwatch()..start();
                      await httpController.fetchProducts();
                      sw.stop();
                      setState(() {
                        httpLoaded = true;
                        httpDurationSec = sw.elapsedMilliseconds / 1000;
                      });
                    },
                    icon: const Icon(Icons.http),
                    label: const Text("Muat via HTTP"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final sw = Stopwatch()..start();
                      await dioController.fetchProducts();
                      sw.stop();
                      setState(() {
                        dioLoaded = true;
                        dioDurationSec = sw.elapsedMilliseconds / 1000;
                      });
                    },
                    icon: const Icon(Icons.cloud_download),
                    label: const Text("Muat via Dio"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildPerformanceTable(),

            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  if (httpLoaded) Obx(() => _buildProductSection(
                      "HTTP", httpController.products, httpController)),
                  if (dioLoaded) Obx(() => _buildProductSection(
                      "Dio", dioController.products, dioController)),
                  if (!httpLoaded && !dioLoaded)
                    const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                        child: Text(
                          "Belum ada data dimuat.\nTekan tombol untuk memulai.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.pink.shade50),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Library", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Waktu (s)", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        _tableRowFromState("HTTP", httpDurationSec, httpLoaded, httpController),
        _tableRowFromState("Dio", dioDurationSec, dioLoaded, dioController),
      ],
    );
  }

  TableRow _tableRowFromState(String name, double? sec, bool loaded, dynamic controller) {
    final statusText = loaded ? "Berhasil" : "Belum";
    final statusColor = loaded ? Colors.green : Colors.red;
    final serverTime = (controller is ProductControllerHttp || controller is ProductControllerDio)
        ? (controller.responseTimeMs.value / 1000)
        : null;

    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(name)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(sec != null ? sec.toStringAsFixed(2) : "-"),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              if (loaded && serverTime != null)
                Text("(srv ${serverTime.toStringAsFixed(2)} s)",
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductSection(String title, List<ProductModel> products, dynamic controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$title (${products.length})",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
        const SizedBox(height: 8),
        products.isEmpty
            ? const Center(child: Text("Tidak ada data."))
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  final p = products[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.network(
                            p.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("Rp ${p.price.toStringAsFixed(0)}", style: const TextStyle(color: Colors.pinkAccent)),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
        const SizedBox(height: 20),
      ],
    );
  }
}
