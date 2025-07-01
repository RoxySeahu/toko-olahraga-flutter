// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/product_provider.dart';
import 'package:toko_olahraga/widgets/product_item.dart';
import 'package:toko_olahraga/widgets/app_drawer.dart';
import 'package:toko_olahraga/providers/cart_provider.dart';
import 'package:toko_olahraga/screens/category/category_products_screen.dart';
import 'package:toko_olahraga/models/product.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

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

  final ScrollController _categoryScrollController = ScrollController();

  final Map<String, IconData> _categoryIcons = {
    'PeralatanGym': Icons.fitness_center,
    'Renang': Icons.pool,
    'Sepatu': Icons.directions_run,
    'Aksesoris': Icons.watch,
    'Bola': Icons.sports_baseball,
    'Raket': Icons.sports_tennis,
    'Alat Pelindung': Icons.safety_divider,
    'Supplement': Icons.medical_services,
    'Obat': Icons.medical_information,
    'Buku': Icons.book,
    'Lainnya': Icons.category,
  };

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
          SnackBar(
            content: Text('Gagal memuat produk: $error'),
            backgroundColor: Colors.redAccent,
          ),
        );
        debugPrint('Error fetching products: $error');
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
    setState(() {
      _isLoadingData = true;
    });
    try {
      await Provider.of<ProductsProvider>(context, listen: false).fetchAndSetProducts();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat ulang produk: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);

    final productsToDisplay = _isSearching
        ? _filteredProducts
        : _showFavoritesOnly
            ? productsData.favoriteProducts
            : productsData.products;

    final List<String> categories = productsData.categories;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 4,
        title: _isSearching
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: _filterProducts,
                ),
              )
            : const Text(
                'Toko Olahraga',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            icon: const Icon(Icons.filter_list),
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
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
              child: ch!,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed('/cart');
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : RefreshIndicator(
              onRefresh: () => _refreshProducts(context),
              color: Colors.teal,
              child: productsToDisplay.isEmpty && _searchController.text.isEmpty && !_showFavoritesOnly
                  ? Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sentiment_dissatisfied, size: 100, color: Colors.grey[400]),
                            const SizedBox(height: 20),
                            const Text(
                              'Oops! Tidak ada produk yang tersedia saat ini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Tarik ke bawah untuk memuat ulang, atau cek kategori lain.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              onPressed: () => _refreshProducts(context),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Muat Ulang Produk'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
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
                          // --- Bagian Background Image (Hero) ---
                          // Menggunakan Stack untuk menumpuk gambar dan teks
                          Container(
                            height: 180, // Sesuaikan tinggi banner
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack( // Gunakan Stack di sini
                              children: [
                                // Background Image
                                ClipRRect( // Tambahkan ClipRRect untuk membulatkan gambar
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Image.asset(
                                    'assets/images/bg_banner.jpg', // Ganti dengan path aset Anda
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                // Optional: Overlay gelap atau gradient untuk teks lebih jelas
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.6), // Mulai gelap di bawah
                                          Colors.transparent, // Transparan di atas
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Text (di atas gambar)
                                const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center, // Pusatkan teks secara vertikal
                                    crossAxisAlignment: CrossAxisAlignment.start, // Ratakan teks ke kiri
                                    children: [
                                      Text(
                                        'Dapatkan Peralatan Terbaik!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 5.0,
                                              color: Colors.black54,
                                              offset: Offset(2.0, 2.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Dengan Kualitas Premium', 
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 5.0,
                                              color: Colors.black54,
                                              offset: Offset(1.0, 1.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20), // Spasi setelah banner

                          // --- Bagian Kategori (Section Header & Horizontal List) ---
                          if (!_isSearching && categories.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Jelajahi Kategori',
                                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  SizedBox(
                                    height: 100,
                                    child: Scrollbar(
                                      controller: _categoryScrollController,
                                      thumbVisibility: true,
                                      trackVisibility: true,
                                      thickness: 6.0,
                                      radius: const Radius.circular(3),
                                      child: ListView.builder(
                                        controller: _categoryScrollController,
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.only(bottom: 10.0),
                                        itemCount: categories.length,
                                        itemBuilder: (ctx, i) {
                                          final categoryName = categories[i];
                                          final iconData = _categoryIcons[categoryName] ?? Icons.category;

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                            child: ActionChip(
                                              label: Text(
                                                categoryName,
                                                style: const TextStyle(color: Colors.blueGrey),
                                              ),
                                              avatar: Icon(iconData, color: Colors.teal.withOpacity(0.7)),
                                              onPressed: () {
                                                Navigator.of(context).pushNamed(
                                                  CategoryProductsScreen.routeName,
                                                  arguments: {
                                                    'categoryName': categoryName,
                                                    'categoryTitle': categoryName,
                                                  },
                                                );
                                              },
                                              backgroundColor: Colors.teal.withOpacity(0.08),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30.0),
                                                side: BorderSide(color: Colors.teal.withOpacity(0.3)),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (!_isSearching && categories.isNotEmpty) const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16, color: Colors.grey),

                          // --- Bagian Produk (Section Header & Grid) ---
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
                            child: Text(
                              _isSearching
                                  ? 'Hasil Pencarian Produk'
                                  : (_showFavoritesOnly ? 'Produk Favorit Pilihan Anda' : 'Produk Terbaru Kami'),
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                            ),
                          ),
                          _isSearching && _filteredProducts.isEmpty && _searchController.text.isNotEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(30.0),
                                    child: Column(
                                      children: [
                                        Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                                        const SizedBox(height: 15),
                                        const Text(
                                          'Tidak ada produk yang cocok dengan pencarian Anda.',
                                          style: TextStyle(fontSize: 18, color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.all(12.0),
                                  itemCount: productsToDisplay.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.75,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
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