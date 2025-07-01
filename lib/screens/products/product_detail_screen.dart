import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/cart_provider.dart';
import 'package:toko_olahraga/providers/product_provider.dart';
import 'package:intl/intl.dart'; // Import intl

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct = Provider.of<ProductsProvider>(
      context,
      listen: false,
    ).findById(productId);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2); // Formatter

    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.name),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                image: DecorationImage(
                  image: NetworkImage(loadedProduct.imageUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    debugPrint('Error memuat gambar di detail screen: $exception');
                  },
                ),
              ),
              child: loadedProduct.imageUrl.isEmpty
                  ? const Center(child: Icon(Icons.broken_image, size: 100, color: Colors.grey))
                  : null,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                // Format harga
                currencyFormatter.format(loadedProduct.price),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              width: double.infinity,
              child: Text(
                loadedProduct.description,
                textAlign: TextAlign.justify,
                softWrap: true,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // FIX: Pass only the loadedProduct object
                cart.addItem(loadedProduct);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Produk berhasil ditambahkan ke keranjang!',
                      textAlign: TextAlign.center,
                    ),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'BATALKAN',
                      onPressed: () {
                        cart.removeSingleItem(loadedProduct.id);
                      },
                      textColor: Colors.amber,
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(10),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text(
                'Tambah ke Keranjang',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 5,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}