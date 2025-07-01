// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/cart_provider.dart';
import 'package:toko_olahraga/models/cart_item.dart'; // Pastikan ini diimpor jika digunakan
import 'package:toko_olahraga/models/product.dart'; // Pastikan ini diimpor jika digunakan
import 'package:toko_olahraga/screens/checkout/checkout_screen.dart';
import 'package:toko_olahraga/widgets/cart_item_widget.dart'; // Ini akan tetap dipakai
import 'package:intl/intl.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0); // Ubah decimalDigits ke 0 untuk tampilan Rupiah lebih rapi

    // Definisikan skema warna utama
    const Color primaryColor = Color(0xFF1976D2); // Biru yang kuat
    const Color accentColor = Color(0xFF42A5F5); // Biru yang lebih terang
    const Color textColor = Color(0xFF333333); // Teks gelap
    const Color lightGrey = Color(0xFFF5F5F5); // Latar belakang abu-abu muda
    const Color darkGrey = Color(0xFF616161); // Teks abu-abu gelap

    return Scaffold(
      backgroundColor: lightGrey, // Latar belakang keseluruhan yang lebih terang
      appBar: AppBar(
        title: const Text(
          'Keranjang Belanja Anda', // Judul yang lebih deskriptif
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor, // Warna app bar yang konsisten
        elevation: 4, // Sedikit bayangan untuk app bar
        iconTheme: const IconThemeData(color: Colors.white), // Warna ikon di app bar
      ),
      body: Column(
        children: [
          // Header Ringkasan Keranjang
          Container(
            margin: const EdgeInsets.only(bottom: 15.0),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // Pergeseran bayangan
                ),
              ],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Flexible( // Menggunakan Flexible untuk mencegah overflow pada teks panjang
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0), // Beri sedikit jarak
                    child: FittedBox( // Pastikan teks muat
                      fit: BoxFit.scaleDown,
                      child: Text(
                        currencyFormatter.format(cart.totalAmount),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor, // Warna yang menonjol untuk total
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Daftar Item Keranjang
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 100, // Ukuran ikon lebih besar
                          color: darkGrey.withOpacity(0.4), // Warna ikon abu-abu transparan
                        ),
                        const SizedBox(height: 20), // Jarak lebih besar
                        const Text(
                          'Keranjang belanja Anda masih kosong!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Ayo temukan produk olahraga favoritmu sekarang.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(); // Kembali ke layar sebelumnya (biasanya home)
                          },
                          icon: const Icon(Icons.shopping_cart_outlined, size: 24),
                          label: const Text('Mulai Belanja', style: TextStyle(fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor, // Warna tombol yang menarik
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0), // Tombol lebih bulat
                            ),
                            elevation: 5, // Bayangan tombol
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10.0), // Padding untuk daftar item
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final cartItem = cart.items.values.toList()[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Dismissible(
                          key: ValueKey(cartItem.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(15.0), // Sudut bulat untuk background dismiss
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 25), // Padding ikon hapus
                            child: const Icon(
                              Icons.delete_forever, // Ikon hapus yang lebih kuat
                              color: Colors.white,
                              size: 35, // Ukuran ikon lebih besar
                            ),
                          ),
                          confirmDismiss: (direction) {
                            return showDialog(
                              context: ctx,
                              builder: (ctx) => AlertDialog(
                                title: const Text(
                                  'Hapus dari Keranjang?',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                                ),
                                content: Text(
                                  'Apakah Anda yakin ingin menghapus "${cartItem.name}" dari keranjang Anda?',
                                  style: const TextStyle(color: darkGrey),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Tidak', style: TextStyle(color: primaryColor)),
                                    onPressed: () {
                                      Navigator.of(ctx).pop(false);
                                    },
                                  ),
                                  ElevatedButton( // Menggunakan ElevatedButton untuk 'Ya'
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.error,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Ya'),
                                    onPressed: () {
                                      Navigator.of(ctx).pop(true);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (direction) {
                            cart.removeItem(cartItem.productId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${cartItem.name} telah dihapus dari keranjang.',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: primaryColor, // Warna snackbar yang lebih baik
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating, // Snackbar mengambang
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.all(10),
                              ),
                            );
                          },
                          child: CartItemWidget(
                            cartItem: cartItem,
                            currencyFormatter: currencyFormatter,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -3), // Bayangan di bagian atas
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea( // Pastikan konten tidak terhalang notch atau gesture area
          child: ElevatedButton(
            onPressed: cart.totalAmount <= 0
                ? null // Tombol dinonaktifkan jika keranjang kosong
                : () {
                    Navigator.of(context).pushNamed(CheckoutScreen.routeName);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor, // Warna utama untuk tombol checkout
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), // Lebih bulat
              ),
              elevation: 0, // Tidak ada bayangan tambahan karena container sudah ada bayangan
              disabledBackgroundColor: Colors.grey[300], // Warna tombol saat dinonaktifkan
              disabledForegroundColor: Colors.grey[600], // Warna teks saat dinonaktifkan
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payment, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'LANJUTKAN KE CHECKOUT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}