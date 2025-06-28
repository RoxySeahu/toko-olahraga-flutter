// lib/screens/checkout/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/cart_provider.dart';
import 'package:toko_olahraga/screens/home/home_screen.dart'; // Untuk navigasi kembali ke home

class CheckoutScreen extends StatefulWidget {
  static const routeName = '/checkout';

  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _notesController = TextEditingController();
  String? _selectedPaymentMethodCategory;
  String? _selectedBank;
  String? _selectedMobilePay;
  bool _isProcessingOrder = false;

  final _formKey = GlobalKey<FormState>();

  void _placeOrder() async {
    // Validasi input DropdownButtonFormField (jika salah satu kategori dipilih)
    if (_selectedPaymentMethodCategory == 'bank' && _selectedBank == null) {
      _formKey.currentState!.validate(); // Trigger validation for dropdown
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih bank Anda.')),
      );
      return;
    }
    if (_selectedPaymentMethodCategory == 'mobile' && _selectedMobilePay == null) {
      _formKey.currentState!.validate(); // Trigger validation for dropdown
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih metode pembayaran mobile Anda.')),
      );
      return;
    }


    if (_selectedPaymentMethodCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih kategori metode pembayaran (Bank atau Mobile Payment).')),
      );
      return;
    }


    setState(() {
      _isProcessingOrder = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    final cart = Provider.of<CartProvider>(context, listen: false);
    final totalAmount = cart.totalAmount;
    final orderNotes = _notesController.text;

    String paymentDetail = '';
    if (_selectedPaymentMethodCategory == 'bank') {
      paymentDetail = 'Transfer Bank: ${_selectedBank!}';
    } else if (_selectedPaymentMethodCategory == 'mobile') {
      paymentDetail = 'Mobile Payment: ${_selectedMobilePay!}';
    }

    cart.clearCart();

    setState(() {
      _isProcessingOrder = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Pesanan Berhasil Ditempatkan!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Terima kasih atas pesanan Anda.'),
            const SizedBox(height: 10),
            Text('Total Pembayaran: Rp ${totalAmount.toStringAsFixed(2)}'),
            Text('Metode Pembayaran: $paymentDetail'),
            if (orderNotes.isNotEmpty)
              Text('Catatan: $orderNotes'),
            const SizedBox(height: 10),
            if (_selectedPaymentMethodCategory == 'bank')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lakukan transfer ke rekening berikut:'),
                  const SizedBox(height: 5),
                  Text('Bank: ${_selectedBank!}'),
                  const Text('Nomor Rekening: 1234567890 (a/n Toko Olahraga)'),
                  const Text('Kode Transfer (jika ada): 1234'),
                ],
              )
            else if (_selectedPaymentMethodCategory == 'mobile')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lakukan pembayaran melalui aplikasi ${_selectedMobilePay!}.'),
                  const SizedBox(height: 5),
                  const Text('ID/Nomor Telepon: 081234567890 (a/n Toko Olahraga)'),
                  const Text('Atau scan QR Code berikut (simulasi):'),
                  const SizedBox(height: 10),
                  Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Text('QR Code Simulasi', textAlign: TextAlign.center),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            const Text('Detail pembayaran dan konfirmasi akan dikirimkan ke email Anda.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isProcessingOrder
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Memproses pesanan Anda...', style: TextStyle(fontSize: 18)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ringkasan Pesanan',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const Divider(height: 20),
                            ...cart.items.values.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.name} (${item.quantity}x)',
                                      style: const TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text('Rp ${(item.price * item.quantity).toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )).toList(),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Pembayaran',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Rp ${cart.totalAmount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Catatan Pesanan (Opsional)',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'Contoh: Ukuran M untuk sepatu, jangan dibungkus kado',
                                alignLabelWithHint: true,
                              ),
                              maxLines: 3,
                              keyboardType: TextInputType.multiline,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pilih Kategori Pembayaran',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            RadioListTile<String>(
                              title: const Text('Transfer Bank', style: TextStyle(fontSize: 16)),
                              subtitle: const Text('Pembayaran melalui rekening bank'),
                              value: 'bank',
                              groupValue: _selectedPaymentMethodCategory,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethodCategory = value;
                                  _selectedMobilePay = null; // Reset mobile pay
                                });
                              },
                            ),
                            if (_selectedPaymentMethodCategory == 'bank')
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0, right: 8.0, bottom: 8.0),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedBank,
                                  hint: const Text('Pilih Bank'),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                                  ),
                                  items: <String>['Bank BRI', 'Bank BNI', 'Bank Mandiri', 'Bank BCA', 'Bank Lainnya']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedBank = newValue;
                                    });
                                  },
                                  validator: (value) {
                                    if (_selectedPaymentMethodCategory == 'bank' && (value == null || value.isEmpty)) {
                                      return 'Harap pilih bank.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            const Divider(),
                            RadioListTile<String>(
                              title: const Text('Mobile Payment', style: TextStyle(fontSize: 16)),
                              subtitle: const Text('Pembayaran melalui aplikasi dompet digital'),
                              value: 'mobile',
                              groupValue: _selectedPaymentMethodCategory,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethodCategory = value;
                                  _selectedBank = null; // Reset bank
                                });
                              },
                            ),
                            if (_selectedPaymentMethodCategory == 'mobile')
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0, right: 8.0, bottom: 8.0),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedMobilePay,
                                  hint: const Text('Pilih Mobile Payment'),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                                  ),
                                  items: <String>['Dana', 'GoPay', 'OVO', 'LinkAja', 'ShopeePay', 'Lainnya']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedMobilePay = newValue;
                                    });
                                  },
                                  validator: (value) {
                                    if (_selectedPaymentMethodCategory == 'mobile' && (value == null || value.isEmpty)) {
                                      return 'Harap pilih mobile payment.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: cart.totalAmount <= 0 ? null : _placeOrder,
                        icon: const Icon(Icons.payment),
                        label: const Text(
                          'Bayar Sekarang',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}