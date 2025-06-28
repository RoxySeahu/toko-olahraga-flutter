import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/product_provider.dart';
import 'package:toko_olahraga/widgets/product_item.dart';

class CategoryProductsScreen extends StatelessWidget {
  static const routeName = '/category-products';

  final String categoryTitle;
  final String categoryName;

  const CategoryProductsScreen({
    Key? key,
    required this.categoryTitle,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final String actualCategoryTitle = args?['categoryTitle'] ?? categoryTitle;
    final String actualCategoryName = args?['categoryName'] ?? categoryName;

    // Menggunakan Consumer karena data produk sudah tersedia melalui ProductsProvider
    return Consumer<ProductsProvider>(
      builder: (ctx, productsData, child) {
        final categoryProducts = productsData.getProductsByCategory(actualCategoryName);

        return Scaffold(
          appBar: AppBar(
            title: Text(actualCategoryTitle),
          ),
          body: categoryProducts.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada produk dalam kategori ${actualCategoryTitle}.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
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
      },
    );
  }
}