import 'dart:io';
import 'package:flutter/material.dart'; // Untuk debugPrint
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toko_olahraga/models/product.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<String> uploadImageToFirebase(File imageFile, String productId) async {
    try {
      final ref = _storage.ref().child('product_images').child('$productId.jpg');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> addProductToFirestore({
    required String name,
    required String description,
    required double price,
    required File? imageFile,
    required String category,
  }) async {
    String imageUrl = '';
    try {
      final newProductRef = _firestore.collection('products').doc();
      final String productId = newProductRef.id;

      if (imageFile != null) {
        imageUrl = await uploadImageToFirebase(imageFile, productId);
      }

      final newProduct = Product(
        id: productId,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        category: category,
        isFavorite: false,
      );

      await newProductRef.set(newProduct.toFirestore());
      debugPrint('Produk berhasil ditambahkan ke Firestore: ${newProduct.name}');
    } catch (e) {
      debugPrint('Gagal menambahkan produk ke Firestore: $e');
      rethrow;
    }
  }
}