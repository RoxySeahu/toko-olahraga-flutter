// lib/screens/category/category_products_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/product_provider.dart';
import 'package:toko_olahraga/widgets/product_item.dart'; // Pastikan ini diimpor

class CategoryProductsScreen extends StatefulWidget {
  static const routeName = '/category-products'; // Tetapkan routeName

  final String categoryTitle;
  final String categoryName;

  const CategoryProductsScreen({
    Key? key,
    required this.categoryTitle,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  // Pastikan Anda memuat data produk jika belum dimuat atau memfilter dari yang sudah ada
  // Karena ProductsProvider sudah memiliki fetchAndSetProducts() yang dipanggil di HomeScreen,
  // di sini kita hanya perlu mendapatkan produk berdasarkan kategori.

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    // Baris yang Anda minta untuk diperbaiki:
    final categoryProducts = productsData.getProductsByCategory(widget.categoryName); // Memanggil metode yang baru ditambahkan

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: productsData.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryProducts.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada produk di kategori "${widget.categoryTitle}" saat ini.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: categoryProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                    value: categoryProducts[i],
                    child: const ProductItem(),
                  ),
                ),
    );
  }
}