import 'package:flutter/material.dart';

void main() {
  runApp(const KurniaStoreApp());
}

class KurniaStoreApp extends StatelessWidget {
  const KurniaStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KurniaStore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.pinkAccent,
        fontFamily: 'Poppins',
      ),
      home: const HomeScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// 🏠 HOME SCREEN
// ---------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool showAnimation = true;
  late AnimationController _controller;

  // Contoh data produk lokal
  final List<Map<String, dynamic>> products = List.generate(
    8,
    (i) => {
      'name': 'Dress ${i + 1}',
      'price': 120000 + (i * 10000),
      'image': 'assets/images/dress${i + 1}.jpg',
    },
  );

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = width < 600
        ? 2
        : width < 900
            ? 3
            : 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KurniaStore 🛍️',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(showAnimation ? Icons.pause : Icons.play_arrow),
            tooltip: "Toggle Animation",
            onPressed: () {
              setState(() {
                showAnimation = !showAnimation;
              });
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: showAnimation
            ? _buildAnimatedGrid(crossAxisCount)
            : _buildStaticGrid(crossAxisCount),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 🌀 IMPLICIT ANIMATION: AnimatedContainer
  // -------------------------------------------------------------------------
  Widget _buildAnimatedGrid(int crossAxisCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.7,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final color = Colors.primaries[index % Colors.primaries.length].shade100;

        return AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              ),
            ),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                Expanded(
                  child: Hero(
                    tag: product['image'],
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.asset(
                        product['image'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(product['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Rp ${product['price']}",
                    style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // ⚙️ EXPLICIT ANIMATION: Rotating FAB
  // -------------------------------------------------------------------------
  Widget _buildStaticGrid(int crossAxisCount) {
    return Stack(
      children: [
        _buildAnimatedGrid(crossAxisCount),
        Align(
          alignment: Alignment.bottomCenter,
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: FloatingActionButton.extended(
                onPressed: () {},
                label: const Text("KurniaStore"),
                icon: const Icon(Icons.local_mall_outlined),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 📦 DETAIL PRODUK
// ---------------------------------------------------------------------------
class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['name'])),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Hero(
            tag: product['image'],
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: Image.asset(
                product['image'],
                fit: BoxFit.cover,
                height: 350,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Harga: Rp ${product['price']}",
                  style: const TextStyle(fontSize: 18, color: Colors.pinkAccent),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Deskripsi:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Dress wanita dengan bahan lembut, desain modern, dan nyaman dipakai untuk acara santai maupun formal.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
