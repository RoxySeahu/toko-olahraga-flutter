import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/product_provider.dart';
import 'package:toko_olahraga/widgets/product_item.dart';
import 'package:toko_olahraga/widgets/app_drawer.dart';
import 'package:toko_olahraga/providers/cart_provider.dart';
import 'package:toko_olahraga/screens/category/category_products_screen.dart';
import 'package:toko_olahraga/models/product.dart';

class HomeScreen extends StatefulWidget {
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

  // --- START: ICON MAPPING FOR CATEGORIES ---
  final Map<String, IconData> _categoryIcons = {
    'PeralatanGym': Icons.fitness_center,
    'Renang': Icons.pool,
    'Sepatu': Icons.directions_run,
    'Aksesoris': Icons.watch, // Example, adjust as needed
    'Bola': Icons.sports_baseball, // Or Icons.sports_soccer, Icons.sports_basketball
    'Raket': Icons.sports_tennis, // Or Icons.sports_badminton
    'Alat Pelindung': Icons.safety_divider, // Or Icons.sports_handball
    'Supplement': Icons.medical_services, // Or Icons.food_bank for nutrition
    'Obat': Icons.medical_information,
    'Buku': Icons.book,
    'Lainnya': Icons.category, // Default/fallback icon
  };
  // --- END: ICON MAPPING FOR CATEGORIES ---

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
      _isLoadingData = true; // Show loading indicator on refresh
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
      backgroundColor: Colors.grey[50], // Lighter background for a clean look
      appBar: AppBar(
        backgroundColor: Colors.blueAccent, // A more prominent app bar color
        foregroundColor: Colors.white, // White icons and text
        elevation: 4, // Subtle shadow for AppBar
        title: _isSearching
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), // Slightly transparent background for search field
                  borderRadius: BorderRadius.circular(25.0), // Rounded search bar
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0), // Adjust padding
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: _filterProducts,
                ),
              )
            : const Text(
                'Toko Olahraga',
                style: TextStyle(fontWeight: FontWeight.bold), // Bold title
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
            icon: const Icon(Icons.filter_list), // More descriptive icon for filter
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
              backgroundColor: Colors.redAccent, // Red badge for cart count
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
          const SizedBox(width: 8), // Spacing for end of app bar
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : RefreshIndicator(
              onRefresh: () => _refreshProducts(context),
              color: Colors.blueAccent, // Refresh indicator color
              child: productsToDisplay.isEmpty && _searchController.text.isEmpty && !_showFavoritesOnly
                  ? Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(), // Allow scrolling even if empty
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sentiment_dissatisfied, size: 100, color: Colors.blueGrey[200]), // More expressive icon
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
                                backgroundColor: Colors.blueAccent,
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
                          // --- Bagian Kategori (Section Header & Horizontal List) ---
                          if (!_isSearching && categories.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0), // More top padding
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Jelajahi Kategori', // More engaging title
                                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                      ),
                                      // Optional: "Lihat Semua" button for categories
                                      // TextButton(
                                      //   onPressed: () {
                                      //     // Navigate to a screen showing all categories
                                      //   },
                                      //   child: const Text('Lihat Semua', style: TextStyle(color: Colors.blueAccent)),
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(height: 15), // Increased spacing
                                  SizedBox(
                                    height: 100, // Sufficient height for chips and scrollbar
                                    child: Scrollbar(
                                      controller: _categoryScrollController,
                                      thumbVisibility: true,
                                      trackVisibility: true,
                                      thickness: 6.0, // Thinner scrollbar
                                      radius: const Radius.circular(3),
                                      child: ListView.builder(
                                        controller: _categoryScrollController,
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.only(bottom: 10.0), // Space for scrollbar
                                        itemCount: categories.length,
                                        itemBuilder: (ctx, i) {
                                          final categoryName = categories[i];
                                          // Get icon from map, fallback to default if not found
                                          final iconData = _categoryIcons[categoryName] ?? Icons.category;

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6.0), // Closer chips
                                            child: ActionChip(
                                              label: Text(
                                                categoryName,
                                                style: const TextStyle(color: Colors.blueGrey),
                                              ),
                                              avatar: Icon(iconData, color: Colors.blueAccent.withOpacity(0.7)),
                                              onPressed: () {
                                                Navigator.of(context).pushNamed(
                                                  CategoryProductsScreen.routeName,
                                                  arguments: {
                                                    'categoryName': categoryName,
                                                    'categoryTitle': categoryName,
                                                  },
                                                );
                                              },
                                              backgroundColor: Colors.blueAccent.withOpacity(0.08), // Lighter background
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30.0), // More rounded chips
                                                side: BorderSide(color: Colors.blueAccent.withOpacity(0.3)), // Subtle border
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Adjusted padding
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (!_isSearching && categories.isNotEmpty) const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16), // Thin divider

                          // --- Bagian Produk (Section Header & Grid) ---
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0), // Top padding for product section
                            child: Text(
                              _isSearching
                                  ? 'Hasil Pencarian Produk'
                                  : (_showFavoritesOnly ? 'Produk Favorit Pilihan Anda' : 'Produk Terbaru Kami'), // More engaging titles
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                            ),
                          ),
                          _isSearching && _filteredProducts.isEmpty && _searchController.text.isNotEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(30.0),
                                    child: Column(
                                      children: [
                                        Icon(Icons.search_off, size: 80, color: Colors.blueGrey[200]),
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
                                  padding: const EdgeInsets.all(12.0), // Adjusted padding for grid
                                  itemCount: productsToDisplay.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(), // Important for nested scrolling
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.75, // Adjust aspect ratio for better product item display
                                    crossAxisSpacing: 12, // Increased spacing
                                    mainAxisSpacing: 12, // Increased spacing
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