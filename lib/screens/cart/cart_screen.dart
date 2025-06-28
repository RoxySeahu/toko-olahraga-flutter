import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/cart_provider.dart';
import 'package:toko_olahraga/models/cart_item.dart';
import 'package:toko_olahraga/models/product.dart'; 

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
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  TextButton(
                    onPressed: () {
                      if (cart.totalAmount > 0) {
                        // Logika checkout di sini
                        cart.clearCart();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Checkout Berhasil! Keranjang dikosongkan.')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Keranjang Anda kosong.')),
                        );
                      }
                    },
                    child: const Text('CHECKOUT'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: cart.items.isEmpty
                ? const Center(
                    child: Text(
                      'Keranjang Anda kosong. Mulai belanja sekarang!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
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
                            vertical: 4,
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
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 4,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(cartItem.imageUrl),
            onBackgroundImageError: (exception, stackTrace) {
              debugPrint('Error loading image: $exception');
            },
            radius: 25,
          ),
          title: Text(cartItem.name),
          subtitle: Text('Total: Rp ${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  cart.removeSingleItem(cartItem.productId);
                },
              ),
              Text('${cartItem.quantity}x'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  // Bagian ini adalah yang paling mungkin menyebabkan error sebelumnya.
                  // Product model sekarang membutuhkan parameter 'category'.
                  cart.addItem(Product(
                    id: cartItem.productId,
                    name: cartItem.name,
                    description: '', // Desc tidak diperlukan di sini
                    price: cartItem.price,
                    imageUrl: cartItem.imageUrl,
                    category: 'Unknown', // FIX: Tambahkan kategori default.
                                        // Idealnya, jika CartItem menyimpan kategori, gunakan cartItem.category
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}