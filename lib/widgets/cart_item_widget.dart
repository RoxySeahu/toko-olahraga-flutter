// lib/widgets/cart_item_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/models/cart_item.dart';
import 'package:toko_olahraga/providers/cart_provider.dart';
import 'package:toko_olahraga/models/product.dart'; // Pastikan ini diimpor

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({Key? key, required this.cartItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    const String defaultCategory = 'General'; // Mengasumsikan kategori default

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 8,
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade50,
            backgroundImage: cartItem.imageUrl.isNotEmpty
                ? NetworkImage(cartItem.imageUrl) as ImageProvider<Object>
                : const AssetImage('assets/images/placeholder.png'), // Fallback asset
            onBackgroundImageError: (exception, stackTrace) {
              debugPrint('Error memuat gambar di CartItemWidget: $exception');
            },
            child: cartItem.imageUrl.isEmpty
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
            width: 120,
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
                      description: 'Deskripsi tidak tersedia di cart item', // Placeholder
                      price: cartItem.price,
                      imageUrl: cartItem.imageUrl,
                      category: defaultCategory,
                      isFavorite: false,
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