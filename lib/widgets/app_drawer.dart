import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toko_olahraga/screens/auth/login_screen.dart';
import 'package:toko_olahraga/screens/home/home_screen.dart';
import 'package:toko_olahraga/screens/admin/products_management_screen.dart'; // Import

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Menu Toko'),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Toko'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomeScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Keranjang'),
            onTap: () {
              Navigator.of(context).pushNamed('/cart');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings), // Ikon untuk Admin
            title: const Text('Kelola Produk'),
            onTap: () {
              Navigator.of(context).pushNamed(ProductsManagementScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.of(context).pop();
              await FirebaseAuth.instance.signOut();
              // Mengganti semua rute yang ada dengan LoginScreen agar tidak bisa back
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}