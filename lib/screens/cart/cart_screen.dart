import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/cart_provider.dart';
import 'package:toko_olahraga/models/cart_item.dart';
import 'package:toko_olahraga/models/product.dart';
import 'package:toko_olahraga/screens/checkout/checkout_screen.dart'; // Import CheckoutScreen

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
                            vertical: 8, // Margin vertikal ditingkatkan untuk spasi yang lebih baik
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
                        child: CartItemWidget(
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

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({Key? key, required this.cartItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    // Mengasumsikan kategori produk tidak disimpan di CartItem, kita mengaturnya secara default.
    // Idealnya, CartItem juga harus menyimpan kategori jika itu penting untuk logika `addItem`.
    const String defaultCategory = 'General';

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 8, // Margin vertikal ditingkatkan untuk spasi yang lebih baik
      ),
      elevation: 3, // Tambahkan sedikit elevasi
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30, // Avatar sedikit lebih besar
            backgroundColor: Colors.blue.shade50,
            backgroundImage: NetworkImage(cartItem.imageUrl), // Gunakan NetworkImage
            onBackgroundImageError: (exception, stackTrace) {
              debugPrint('Error memuat gambar di CartItemWidget: $exception');
              // Fallback ke ikon jika gambar gagal dimuat
            },
            child: cartItem.imageUrl.isEmpty // Fallback jika URL gambar kosong
                ? const Icon(Icons.sports_soccer, size: 30, color: Colors.blue)
                : null,
          ),
          title: Text(
            cartItem.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Harga: Rp ${cartItem.price.toStringAsFixed(2)}\nTotal: Rp ${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          trailing: SizedBox(
            width: 120, // Beri sedikit lebar untuk baris tombol
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () {
                    cart.removeSingleItem(cartItem.productId);
                  },
                ),
                Text(
                  '${cartItem.quantity}x',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                  onPressed: () {
                    cart.addItem(Product(
                      id: cartItem.productId,
                      name: cartItem.name,
                      description: '',
                      price: cartItem.price,
                      imageUrl: cartItem.imageUrl,
                      category: defaultCategory, // Gunakan defaultCategory di sini
                      isFavorite: false, // Nilai default
                    ));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}