import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/product_provider.dart';
import 'package:toko_olahraga/widgets/product_item.dart';
import 'package:toko_olahraga/widgets/app_drawer.dart';
import 'package:toko_olahraga/providers/cart_provider.dart';
import 'package:toko_olahraga/screens/category/category_products_screen.dart';
import 'package:toko_olahraga/models/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _showFavoritesOnly = false;
  var _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  var _isInit = true;
  var _isLoadingData = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoadingData = true;
      });
      Provider.of<ProductsProvider>(context, listen: false)
          .fetchAndSetProducts()
          .then((_) {
        setState(() {
          _isLoadingData = false;
        });
      }).catchError((error) {
        setState(() {
          _isLoadingData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat produk: $error')),
        );
      });
    }
    _isInit = false;
    super.didChangeDependencies();
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

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);

    final productsToDisplay = _isSearching
        ? _filteredProducts
        : _showFavoritesOnly
            ? productsData.favoriteProducts
            : productsData.products;

    // >>> PENTING: Ambil kategori dari provider <<<
    final List<String> categories = productsData.categories;

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
                  _filteredProducts = [];
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
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refreshProducts(context),
              child: productsToDisplay.isEmpty && _searchController.text.isEmpty && !_showFavoritesOnly
                  ? const Center(
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 80, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              'Tidak ada produk yang tersedia saat ini.\nTarik ke bawah untuk memuat ulang atau tambahkan produk baru di database.',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Bagian Kategori ---
                          // Tampilkan kategori hanya jika ada dan tidak sedang mencari
                          if (!_isSearching && categories.isNotEmpty)
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
                                          child: ActionChip(
                                            label: Text(categories[i]),
                                            onPressed: () {
                                              // >>> PENTING: Navigasi ke CategoryProductsScreen dengan categoryName <<<
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
                          if (!_isSearching && categories.isNotEmpty) const Divider(),

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
                                  itemCount: productsToDisplay.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 3 / 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                                    value: productsToDisplay[i],
                                    child: const ProductItem(),
                                  ),
                                ),
                        ],
                      ),
                    ),
            ),
    );
  }
}