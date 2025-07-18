// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toko_olahraga/screens/cart/cart_screen.dart'; // Import untuk rute keranjang
import 'package:toko_olahraga/screens/admin/products_management_screen.dart'; // Import untuk admin
import 'package:toko_olahraga/utils/constants.dart'; // Import AppConstants untuk adminUids
import 'package:toko_olahraga/screens/home/home_screen.dart'; // Import untuk rute ke home (/)

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // Helper method untuk memeriksa apakah pengguna adalah admin
  bool _isAdmin(User? user) {
    if (user == null) {
      return false;
    }
    // Memeriksa apakah UID pengguna yang login ada di daftar adminUids
    return AppConstants.adminUids.contains(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    // StreamBuilder digunakan untuk mendengarkan perubahan status autentikasi secara real-time
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, authSnapshot) {
        final User? currentUser = authSnapshot.data;
        // Menentukan apakah pengguna saat ini adalah admin
        final bool isAdmin = _isAdmin(currentUser);

        return Drawer(
          child: Column(
            children: <Widget>[
              // Header Drawer
              AppBar(
                title: const Text(
                  'Halo Pengguna!', // Judul drawer
                  style: TextStyle(color: Colors.white), // Teks putih agar kontras dengan teal
                ),
                automaticallyImplyLeading: false, // Jangan tampilkan tombol back otomatis
                backgroundColor: Colors.teal, // Mengubah warna AppBar drawer menjadi teal
              ),
              const Divider(), // Pembatas

              // Opsi Menu 'Keranjang'
              ListTile(
                leading: const Icon(Icons.shopping_cart, color: Colors.teal), // Mengubah warna ikon menjadi teal
                title: const Text(
                  'Keranjang',
                  style: TextStyle(color: Colors.blueGrey), // Menggunakan abu-abu untuk teks menu
                ),
                onTap: () {
                  // Tutup drawer dan navigasi ke CartScreen
                  Navigator.of(context).pop(); // Menutup drawer
                  Navigator.of(context).pushNamed(CartScreen.routeName); // Ini akan menempatkan CartScreen di atas tumpukan
                },
              ),
              const Divider(), // Pembatas

              // Opsi Menu 'Kelola Produk (Admin)'
              // Ini hanya akan muncul jika pengguna yang login adalah admin
              if (isAdmin) // Kondisi: hanya tampil jika isAdmin true
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: Colors.teal), // Mengubah warna ikon menjadi teal
                  title: const Text(
                    'Kelola Produk (Admin/Owner)',
                    style: TextStyle(color: Colors.blueGrey), // Menggunakan abu-abu untuk teks menu
                  ),
                  onTap: () {
                    // Tutup drawer dan navigasi ke ProductsManagementScreen
                    Navigator.of(context).pop(); // Menutup drawer
                    Navigator.of(context).pushReplacementNamed(ProductsManagementScreen.routeName);
                  },
                ),
              if (isAdmin) const Divider(), // Pembatas (juga hanya tampil jika isAdmin true)

              // Opsi Menu 'Logout'
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.teal), // Mengubah warna ikon menjadi teal
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.blueGrey), // Menggunakan abu-abu untuk teks menu
                ),
                onTap: () {
                  Navigator.of(context).pop(); // Tutup drawer
                  // Lakukan sign out dari Firebase Authentication
                  FirebaseAuth.instance.signOut();
                  // Setelah logout, navigasi ke halaman login atau halaman utama
                  Navigator.of(context).pushReplacementNamed('/'); // Mengganti rute dengan Home setelah logout
                },
              ),
            ],
          ),
        );
      },
    );
  }
}