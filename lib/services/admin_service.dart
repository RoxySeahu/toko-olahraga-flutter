// lib/services/admin_service.dart
// ignore_for_file: unused_field

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Diperlukan jika pickImage() masih ada
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toko_olahraga/models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Bisa dihapus jika tidak digunakan

  // Metode ini masih ada karena AddProductScreen menggunakan ImagePicker untuk preview
  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<void> addProductToFirestore({
    required String name,
    required String description,
    required double price,
    required String imageUrl, // Menggunakan URL gambar langsung
    required String category,
  }) async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid == null) {
      debugPrint('Error: Pengguna tidak terautentikasi saat mencoba menambahkan produk.');
      throw Exception('Autentikasi diperlukan untuk menambahkan produk.');
    }

    try {
      final newProductRef = _firestore.collection('products').doc();
      final String productId = newProductRef.id;

      final newProduct = Product(
        id: productId,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl, // Menggunakan imageUrl yang diterima
        category: category,
        isFavorite: false,
        userId: currentUserUid,
      );

      await newProductRef.set(newProduct.toFirestore());
      debugPrint('Produk berhasil ditambahkan ke Firestore: ${newProduct.name}');
    } catch (e) {
      debugPrint('Gagal menambahkan produk ke Firestore melalui AdminService: $e');
      rethrow;
    }
  }

  // >>> Implementasi metode updateProductInFirestore yang benar <<<
  Future<void> updateProductInFirestore({
    required String id, // ID dokumen produk yang akan diupdate
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String category,
  }) async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid == null) {
      debugPrint('Error: Pengguna tidak terautentikasi saat mencoba memperbarui produk.');
      throw Exception('Autentikasi diperlukan untuk memperbarui produk.');
    }

    try {
      // Ambil referensi dokumen produk berdasarkan ID
      final productDocRef = _firestore.collection('products').doc(id);

      // Perbarui data di Firestore
      await productDocRef.update({
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
        // Anda mungkin ingin menambahkan 'updatedAt': Timestamp.now() di sini juga
      });
      debugPrint('Produk dengan ID $id berhasil diperbarui di Firestore.');
    } catch (e) {
      debugPrint('Gagal memperbarui produk dengan ID $id di Firestore melalui AdminService: $e');
      rethrow; // Lemparkan kembali error untuk ditangani di UI
    }
  }

  // Metode untuk menghapus produk dari Firestore (Anda mungkin memiliki ini di ProductsProvider atau AdminService)
  Future<void> deleteProductFromFirestore(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      debugPrint('Produk dengan ID $productId berhasil dihapus dari Firestore');
    } catch (e) {
      debugPrint('Error saat menghapus produk dari Firestore: $e');
      rethrow;
    }
  }
}