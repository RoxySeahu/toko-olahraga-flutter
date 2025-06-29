// lib/screens/admin/products_management_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/product_provider.dart';
import 'package:toko_olahraga/screens/admin/add_product_screen.dart';
// ignore: unused_import
import 'package:toko_olahraga/screens/home/home_screen.dart'; 

class ProductsManagementScreen extends StatefulWidget {
  static const routeName = '/products-management';

  const ProductsManagementScreen({super.key});

  @override
  State<ProductsManagementScreen> createState() => _ProductsManagementScreenState();
}

class _ProductsManagementScreenState extends State<ProductsManagementScreen> {
  var _isInit = true;
  var _isLoadingData = false;

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
    final productsData = Provider.of<ProductsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // >>> PERUBAHAN DI SINI: Selalu arahkan ke HomeScreen secara eksplisit <<<
            // CATATAN PENTING: Ini mengabaikan status autentikasi di main.dart
            // sehingga jika pengguna logout saat di layar ini, mereka akan dibawa ke HomeScreen
            // yang mungkin kurang aman. Pastikan rute '/home' Anda selalu mengarah ke HomeScreen.
            Navigator.of(context).pushReplacementNamed('/home');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(AddProductScreen.routeName);
            },
          ),
        ],
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
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
                      physics: const AlwaysScrollableScrollPhysics(),
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
                                          await productsData.deleteProduct(productsData.products[i].id);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Produk berhasil dihapus!')),
                                          );
                                        } catch (error) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Gagal menghapus produk: $error')),
                                          );
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