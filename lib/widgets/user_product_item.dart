import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/models/product.dart'; // Import Product model
import 'package:toko_olahraga/providers/product_provider.dart'; // Import ProductsProvider

class UserProductItem extends StatelessWidget {
  final Product product;
  final Function refreshProducts; // Callback untuk refresh daftar produk setelah edit/delete

  const UserProductItem({
    super.key,
    required this.product,
    required this.refreshProducts,
  });

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context); // Cache ScaffoldMessenger

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: ListTile(
        title: Text(product.name),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(product.imageUrl),
          onBackgroundImageError: (exception, stackTrace) {
            debugPrint('Error loading product image in UserProductItem: $exception');
          },
        ),
        trailing: SizedBox(
          width: 100, // Memberikan lebar yang cukup untuk Row
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  // Navigasi ke AddProductScreen untuk mengedit produk
                  // Anda perlu membuat AddProductScreen mampu menerima argumen produk untuk edit
                  // Contoh: Navigator.of(context).pushNamed('/add-product', arguments: product.id);
                  debugPrint('Edit produk dengan ID: ${product.id}');
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Fitur edit belum diimplementasikan sepenuhnya!')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                color: Theme.of(context).colorScheme.error,
                onPressed: () async {
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Konfirmasi Hapus'),
                      content: Text('Anda yakin ingin menghapus produk "${product.name}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      await productsProvider.deleteProduct(product.id);
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text('Produk berhasil dihapus!')),
                      );
                      // Panggil callback untuk me-refresh daftar di UserProductsScreen
                      refreshProducts();
                    } catch (error) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Gagal menghapus produk: $error')),
                      );
                      debugPrint('Error deleting product from UserProductItem: $error');
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}