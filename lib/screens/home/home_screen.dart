import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/product_provider.dart';
import 'package:toko_olahraga/widgets/product_item.dart';
import 'package:toko_olahraga/widgets/app_drawer.dart';
import 'package:toko_olahraga/providers/cart_provider.dart';
import 'package:toko_olahraga/screens/category/category_products_screen.dart'; // Import untuk navigasi kategori
import 'package:toko_olahraga/models/product.dart'; // BARIS INI DITAMBAHKAN

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _showFavoritesOnly = false;
  var _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = []; // Tidak ada error lagi setelah import Product

  @override
  void initState() {
    super.initState();
    // Ambil produk saat layar diinisialisasi
    // Perhatikan: `listen: false` di `initState` adalah praktik yang baik.
    Provider.of<ProductsProvider>(context, listen: false).fetchAndSetProducts();
  }

  void _filterProducts(String query) {
    final productsData = Provider.of<ProductsProvider>(context, listen: false);
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = [];
      } else {
        _filteredProducts = productsData.products.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase()) ||
                 product.description.toLowerCase().contains(query.toLowerCase()) ||
                 product.category.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // `listen: true` di `build` untuk merespons perubahan data
    final productsData = Provider.of<ProductsProvider>(context);
    final productsToDisplay = _showFavoritesOnly ? productsData.favoriteProducts : productsData.products;

    // Mendapatkan daftar kategori unik
    final List<String> categories = productsData.products.map((p) => p.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _filterProducts,
              )
            : const Text('Toko Olahraga'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filteredProducts = []; // Hapus produk yang difilter saat pencarian ditutup
                }
              });
            },
          ),
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
            builder: (_, cart, ch) => Badge(
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
      drawer: const AppDrawer(),
      body: productsData.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Bagian Kategori ---
                  if (!_isSearching)
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
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              itemBuilder: (ctx, i) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: ActionChip( // Menggunakan ActionChip untuk kategori yang bisa diklik
                                    label: Text(categories[i]),
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                        CategoryProductsScreen.routeName,
                                        arguments: {
                                          'categoryName': categories[i],
                                          'categoryTitle': categories[i],
                                        },
                                      );
                                    },
                                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      side: BorderSide(color: Theme.of(context).primaryColor),
                                    ),
                                    labelPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!_isSearching) const Divider(),

                  // --- Bagian Produk ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      _isSearching
                          ? 'Hasil Pencarian'
                          : (_showFavoritesOnly ? 'Produk Favorit Anda' : 'Semua Produk'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _isSearching && _filteredProducts.isEmpty && _searchController.text.isNotEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'Tidak ada produk yang cocok dengan pencarian Anda.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(10.0),
                          itemCount: _isSearching ? _filteredProducts.length : productsToDisplay.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                            value: _isSearching ? _filteredProducts[i] : productsToDisplay[i],
                            child: const ProductItem(),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}