// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/product_provider.dart';
import 'package:toko_olahraga/widgets/app_drawer.dart';
import 'package:toko_olahraga/widgets/user_product_item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProductsScreen extends StatefulWidget {
  static const routeName = '/user-products';

  const UserProductsScreen({super.key});

  @override
  State<UserProductsScreen> createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductsProvider>(context, listen: false)
          .fetchAndSetProducts()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat produk Anda: $error')),
        );
        debugPrint('Error fetching user products: $error');
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
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Filter produk berdasarkan UID pengguna yang sedang login
    final userProducts = productsData.products.where((product) {
      return product.userId == currentUser?.uid;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/add-product');
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refreshProducts(context),
              child: userProducts.isEmpty
                  ? const Center(
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 80, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              'Belum ada produk yang Anda tambahkan.\nTarik ke bawah untuk memuat ulang.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 20),
                            Text('Atau tambahkan produk baru dengan tombol (+) di atas.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: userProducts.length,
                      itemBuilder: (ctx, i) => Column(
                        children: [
                          UserProductItem(
                            product: userProducts[i],
                            refreshProducts: () => _refreshProducts(context),
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
            ),
    );
  }
}