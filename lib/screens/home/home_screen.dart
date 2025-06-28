import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/product_provider.dart';
import 'package:toko_olahraga/widgets/product_item.dart';
import 'package:toko_olahraga/widgets/app_drawer.dart';
import 'package:toko_olahraga/providers/cart_provider.dart'; // Untuk badge keranjang

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _showFavoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    final products = _showFavoritesOnly ? productsData.favoriteProducts : productsData.products;

    // Mendapatkan daftar kategori unik
    final List<String> categories = productsData.products.map((p) => p.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toko Olahraga'),
        actions: [
          PopupMenuButton(
            onSelected: (bool selectedValue) {
              setState(() {
                _showFavoritesOnly = selectedValue;
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: true,
                child: Text('Hanya Favorit'),
              ),
              const PopupMenuItem(
                value: false,
                child: Text('Tampilkan Semua'),
              ),
            ],
          ),
          Consumer<CartProvider>(
            builder: (_, cart, ch) => Badge( // Menggunakan Badge untuk jumlah item keranjang
              label: Text(cart.itemCount.toString()),
              child: ch!,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed('/cart');
              },
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(), // Menambahkan Drawer
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian Kategori ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kategori',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50, // Tinggi untuk baris kategori horizontal
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (ctx, i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Chip( // Menggunakan Chip untuk tampilan kategori yang lebih modern
                            label: Text(categories[i]),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Mengurangi padding internal
                            onDeleted: null, // Atur ke null jika tidak ada fungsi delete
                            labelPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            side: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            // --- Bagian Produk ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                _showFavoritesOnly ? 'Produk Favorit Anda' : 'Semua Produk',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: products.length,
              shrinkWrap: true, // Penting agar GridView bisa di dalam SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // Nonaktifkan scroll GridView sendiri
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                value: products[i],
                child: const ProductItem(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}