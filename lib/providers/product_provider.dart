import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toko_olahraga/models/product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products {
    return [..._products];
  }

  List<Product> get favoriteProducts {
    return _products.where((prod) => prod.isFavorite).toList();
  }

  bool get isLoading => _isLoading;

  Product findById(String id) {
    return _products.firstWhere((prod) => prod.id == id);
  }

  List<Product> getProductsByCategory(String categoryName) {
    return _products.where((product) => product.category == categoryName).toList();
  }

  Future<void> fetchAndSetProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();
      final List<Product> loadedProducts = [];
      for (var doc in querySnapshot.docs) {
        loadedProducts.add(Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id));
      }
      _products = loadedProducts;
    } catch (error) {
      debugPrint('Error fetching products: $error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Metode untuk menambahkan produk (akan dipanggil dari AdminService atau langsung dari UI admin)
  Future<void> addProduct(Product product) async {
    try {
      // Jika product.id sudah ada (misal dari edit), gunakan itu. Jika tidak, Firestore akan membuat ID baru.
      await FirebaseFirestore.instance.collection('products').doc(product.id.isEmpty ? null : product.id).set(product.toFirestore());
      await fetchAndSetProducts(); // Muat ulang daftar produk setelah penambahan
    } catch (error) {
      debugPrint('Error adding product: $error');
      rethrow;
    }
  }

  // Metode untuk menghapus produk
  Future<void> deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      _products.removeWhere((prod) => prod.id == productId);
      notifyListeners();
      await fetchAndSetProducts(); // Muat ulang setelah penghapusan
    } catch (error) {
      debugPrint('Error deleting product: $error');
      rethrow;
    }
  }
}