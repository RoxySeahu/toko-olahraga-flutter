// lib/providers/product_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

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

  // >>> TAMBAHKAN METODE INI <<<
  List<Product> getProductsByCategory(String categoryName) {
    return _products.where((prod) => prod.category == categoryName).toList();
  }
  // >>> AKHIR TAMBAHAN <<<

  Future<void> fetchAndSetProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('products').get();
      final List<Product> loadedProducts = [];
      querySnapshot.docs.forEach((doc) {
        loadedProducts.add(Product.fromFirestore(doc.data(), doc.id));
      });
      _products = loadedProducts;
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching products: $error');
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

  Future<void> deleteProduct(String id) async {
    final existingProductIndex = _products.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _products[existingProductIndex];
    _products.removeAt(existingProductIndex);
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('products').doc(id).delete();
    } catch (error) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      debugPrint('Error deleting product: $error');
      rethrow;
    }
  }
}