import 'package:flutter/material.dart';
import 'package:toko_olahraga/widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Anda'),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('Halaman Pesanan Belum Diimplementasikan!'),
      ),
    );
  }
}