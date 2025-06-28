import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/product_provider.dart';
import 'package:toko_olahraga/screens/admin/add_product_screen.dart'; // Import AddProductScreen

class ProductsManagementScreen extends StatelessWidget {
  static const routeName = '/products-management';

  const ProductsManagementScreen({Key? key}) : super(key: key);

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    // Memanggil fetchAndSetProducts() saat layar pertama kali dibangun
    _refreshProducts(context);

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
      body: RefreshIndicator( // Menambahkan fitur pull-to-refresh
        onRefresh: () => _refreshProducts(context),
        child: Consumer<ProductsProvider>(
          builder: (ctx, productsData, _) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: productsData.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productsData.products.isEmpty
                    ? const Center(child: Text('Belum ada produk. Tambahkan sekarang!'))
                    : ListView.builder(
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
                                    // IconButton( // Tombol edit (opsional untuk diimplementasikan)
                                    //   icon: const Icon(Icons.edit),
                                    //   onPressed: () {
                                    //     // TODO: Navigasi ke AddProductScreen dalam mode edit
                                    //   },
                                    //   color: Theme.of(context).primaryColor,
                                    // ),
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
                                            await productsData.deleteProduct(productsData.products[i].id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Produk berhasil dihapus!')),
                                            );
                                          } catch (error) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Gagal menghapus produk: $error')),
                                            );
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
        ),
      ),
    );
  }
}