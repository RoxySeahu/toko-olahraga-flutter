import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;

  List<Product> get products {
    return [..._products];
  }

  List<Product> get favoriteProducts {
    return _products.where((prod) => prod.isFavorite).toList();
  }

  List<String> get categories {
    return [..._categories];
  }

  bool get isLoading => _isLoading;

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
          debugPrint('ProductProvider: Dimuat: ${doc.id} - ${doc.data()['name']} - Kategori: ${doc.data()['category']}');
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
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final docRef = await FirebaseFirestore.instance.collection('products').add(product.toFirestore());
      final newProduct = product.copyWith(id: docRef.id);
      _products.add(newProduct);
      notifyListeners();
      debugPrint('ProductProvider: Produk ${newProduct.name} berhasil ditambahkan dengan ID: ${newProduct.id}.');
    } catch (error) {
      debugPrint('ProductProvider: Gagal menambahkan produk: $error');
      rethrow;
    }
  }

  // >>> PASTIKAN METODE INI ADA DAN BENAR <<<
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
      // Rollback jika gagal
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      debugPrint('ProductProvider: Gagal menghapus produk dengan ID $id dari Firestore: $error');
      rethrow;
    }
  }
  // >>> AKHIR METODE DELETEPRODUCT <<<

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