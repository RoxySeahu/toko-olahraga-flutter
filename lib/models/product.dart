import 'package:flutter/foundation.dart';

class Product with ChangeNotifier {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  // Ubah ini dari parameter bernama menjadi parameter opsional biasa,
  // atau beri nama parameter yang tidak diawali underscore.
  // Pilihan terbaik adalah langsung inisialisasi field privat.
  bool _isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    bool isFavorite = false, // Ganti `this._isFavorite` menjadi `bool isFavorite`
  }) : _isFavorite = isFavorite; // Inisialisasi field privat di initializer list

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      isFavorite: data['isFavorite'] ?? false, // Pastikan ini juga menggunakan `isFavorite`
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isFavorite': _isFavorite,
    };
  }

  bool get isFavorite => _isFavorite;

  void toggleFavoriteStatus() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }
}