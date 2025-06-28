import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/cart_provider.dart';
import 'package:toko_olahraga/screens/checkout/checkout_screen.dart';
import 'package:toko_olahraga/widgets/cart_item_widget.dart'; // Import CartItemWidget dari folder widgets

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      'Rp ${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: cart.totalAmount <= 0
                        ? null // Nonaktifkan tombol jika keranjang kosong
                        : () {
                            Navigator.of(context).pushNamed(CheckoutScreen.routeName);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('CHECKOUT', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: cart.items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          'Keranjang Anda kosong.\nMulai belanja sekarang!',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final cartItem = cart.items.values.toList()[i];
                      return Dismissible(
                        key: ValueKey(cartItem.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Theme.of(context).colorScheme.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        confirmDismiss: (direction) {
                          return showDialog(
                            context: ctx,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Apakah Anda yakin?'),
                              content: const Text(
                                  'Apakah Anda ingin menghapus item dari keranjang?'),
                              actions: [
                                TextButton(
                                  child: const Text('Tidak'),
                                  onPressed: () {
                                    Navigator.of(ctx).pop(false);
                                  },
                                ),
                                TextButton(
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
                              content: Text('${cartItem.name} dihapus dari keranjang.'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: CartItemWidget( // Menggunakan widget CartItemWidget terpisah
                          cartItem: cartItem,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}