// lib/screens/admin/products_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/product_provider.dart';
import 'package:toko_olahraga/screens/admin/add_product_screen.dart';

class ProductsManagementScreen extends StatefulWidget {
  static const routeName = '/products-management';

  const ProductsManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProductsManagementScreen> createState() => _ProductsManagementScreenState();
}

class _ProductsManagementScreenState extends State<ProductsManagementScreen> {
  var _isInit = true; // Flag untuk pemuatan data pertama kali
  var _isLoadingData = false; // Status loading untuk layar ini

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoadingData = true; // Memulai loading
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
          SnackBar(content: Text('Gagal memuat produk untuk manajemen: $error')),
        );
        debugPrint('Error fetching products for management: $error');
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    // Consumer digunakan agar UI bereaksi terhadap perubahan pada ProductsProvider
    final productsData = Provider.of<ProductsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(AddProductScreen.routeName);
            },
          ),
        ],
      ),
      body: _isLoadingData // Tampilkan CircularProgressIndicator saat loading data
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator( // Menambahkan fitur pull-to-refresh
              onRefresh: () => _refreshProducts(context),
              child: productsData.products.isEmpty
                  ? const Center(
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 80, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              'Belum ada produk. Tambahkan sekarang!\nTarik ke bawah untuk memuat ulang.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(), // Agar RefreshIndicator berfungsi
                      itemCount: productsData.products.length,
                      itemBuilder: (_, i) => Column(
                        children: [
                          ListTile(
                            title: Text(productsData.products[i].name),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(productsData.products[i].imageUrl),
                              onBackgroundImageError: (exception, stackTrace) {
                                debugPrint('Error loading image in management screen: $exception');
                              },
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      // Konfirmasi penghapusan
                                      final bool? confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Konfirmasi'),
                                          content: Text('Apakah Anda yakin ingin menghapus ${productsData.products[i].name}?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(false),
                                              child: const Text('Tidak'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(true),
                                              child: const Text('Ya'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        try {
                                          // BARIS YANG DIMAKSUD
                                          await productsData.deleteProduct(productsData.products[i].id);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Produk berhasil dihapus!')),
                                          );
                                        } catch (error) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Gagal menghapus produk: $error')),
                                          );
                                          // Log error lebih detail ke konsol
                                          debugPrint('Error from deleteProduct call in ProductsManagementScreen: $error');
                                        }
                                      }
                                    },
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
            ),
    );
  }
}