import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];
  List<String> _categories = [];
  bool _isLoading = false; // Status loading global (tidak selalu digunakan jika dihandle per layar)

  List<Product> get products {
    return [..._products];
  }

  List<Product> get favoriteProducts {
    return _products.where((prod) => prod.isFavorite).toList();
  }

  List<String> get categories {
    return [..._categories];
  }

  bool get isLoading => _isLoading; // Getter untuk status loading

  Product findById(String id) {
    try {
      return _products.firstWhere((prod) => prod.id == id);
    } catch (e) {
      debugPrint('ProductProvider: Produk dengan ID $id tidak ditemukan: $e');
      throw Exception('Produk dengan ID $id tidak ditemukan!');
    }
  }

  List<Product> getProductsByCategory(String categoryName) {
    return _products.where((prod) => prod.category == categoryName).toList();
  }

  Future<void> fetchAndSetProducts() async {
    // _isLoading = true; // Jika Anda ingin ini menjadi status loading global
    // notifyListeners();

    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('products').get();
      final List<Product> loadedProducts = [];
      final Set<String> uniqueCategories = {};

      if (querySnapshot.docs.isEmpty) {
        debugPrint('ProductProvider: Tidak ada dokumen ditemukan di koleksi "products".');
      }

      for (var doc in querySnapshot.docs) {
        try {
          final product = Product.fromFirestore(doc.data(), doc.id);
          loadedProducts.add(product);
          uniqueCategories.add(product.category);
          // debugPrint('ProductProvider: Dimuat: ${doc.id} - ${doc.data()['name']} - Kategori: ${doc.data()['category']}');
        } catch (e) {
          debugPrint('ProductProvider: Error parsing product ${doc.id}: $e - Data: ${doc.data()}');
        }
      }
      _products = loadedProducts;
      _categories = uniqueCategories.toList();
      _categories.sort();
      debugPrint('ProductProvider: Total produk berhasil dimuat: ${_products.length}');
      debugPrint('ProductProvider: Kategori yang dimuat: $_categories');

    } catch (error) {
      debugPrint('ProductProvider: Error fetching products from Firestore: $error');
      rethrow;
    } finally {
      // _isLoading = false; // Jika Anda ingin ini menjadi status loading global
      notifyListeners(); // Penting untuk memberi tahu Consumer agar UI diperbarui
    }
  }

  // Metode untuk menambahkan produk (digunakan oleh AdminService, bukan ProductProvider langsung)
  // Biarkan kosong atau hapus jika AdminService yang menanganinya sepenuhnya
  /*
  Future<void> addProduct(Product product) async {
    // Implementasi ini seharusnya sudah di AdminService.
    // Jika Anda punya versi ini di sini, bisa dihapus atau diadaptasi.
  }
  */

  Future<void> deleteProduct(String id) async {
    final existingProductIndex = _products.indexWhere((prod) => prod.id == id);
    if (existingProductIndex < 0) {
      debugPrint('ProductProvider: Produk dengan ID $id tidak ditemukan di daftar lokal.');
      return;
    }

    final Product existingProduct = _products[existingProductIndex];

    _products.removeAt(existingProductIndex);
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('products').doc(id).delete();
      debugPrint('ProductProvider: Produk dengan ID $id berhasil dihapus dari Firestore.');
    } catch (error) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      debugPrint('ProductProvider: Gagal menghapus produk dengan ID $id dari Firestore: $error');
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _products.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      try {
        await FirebaseFirestore.instance.collection('products').doc(id).update(newProduct.toFirestore());
        _products[prodIndex] = newProduct;
        notifyListeners();
      } catch (error) {
        debugPrint('Error updating product: $error');
        rethrow;
      }
    }
  }
}