import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/cart_provider.dart';
import 'package:toko_olahraga/screens/home/home_screen.dart';
import 'package:intl/intl.dart';

// --- MODEL ALAMAT SEMENTARA (untuk CRUD di memori) ---
class Address {
  String id;
  String receiverName;
  String phoneNumber;
  String fullAddress;
  String city;
  String postalCode;

  Address({
    required this.id,
    required this.receiverName,
    required this.phoneNumber,
    required this.fullAddress,
    required this.city,
    required this.postalCode,
  });

  String get displayAddress {
    return '$fullAddress, $city - $postalCode\nTelp: $phoneNumber';
  }
}
// --- AKHIR MODEL ALAMAT SEMENTARA ---

class CheckoutScreen extends StatefulWidget {
  static const routeName = '/checkout';

  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _notesController = TextEditingController();
  final _accountNumberController = TextEditingController(); // Untuk nomor rekening bank
  final _mobilePaymentNumberController = TextEditingController(); // Untuk nomor mobile payment
  final _addressFormKey = GlobalKey<FormState>(); // Key untuk form tambah/edit alamat
  final _addressReceiverNameController = TextEditingController();
  final _addressPhoneNumberController = TextEditingController();
  final _addressFullAddressController = TextEditingController();
  final _addressCityController = TextEditingController();
  final _addressPostalCodeController = TextEditingController();

  String? _selectedPaymentMethodCategory;
  String? _selectedBank;
  String? _selectedMobilePay;
  String? _selectedShippingOption;
  String _shippingEstimate = ''; // Estimasi waktu pengiriman yang akan ditampilkan
  
  Address? _selectedAddress; // Alamat yang dipilih untuk pengiriman
  List<Address> _userAddresses = []; // Daftar alamat pengguna (disimpan di memori untuk sesi ini)
  Address? _editingAddress; // Alamat yang sedang diedit (null jika menambah baru)

  bool _isProcessingOrder = false; // Status saat memproses pesanan

  final _formKey = GlobalKey<FormState>(); // Key untuk form utama checkout

  // Harga pengiriman per opsi
  final Map<String, double> _shippingCosts = {
    'Reguler': 15000.0,
    'Kargo': 30000.0,
    'Instan': 50000.0,
  };

  // Estimasi waktu pengiriman per opsi
  final Map<String, String> _deliveryEstimates = {
    'Reguler': '5-8 hari kerja',
    'Kargo': '3-5 hari kerja',
    'Instan': '1-2 hari kerja',
  };

  // Getter untuk mendapatkan biaya pengiriman saat ini berdasarkan opsi yang dipilih
  double get _currentShippingCost {
    return _selectedShippingOption != null ? _shippingCosts[_selectedShippingOption!] ?? 0.0 : 0.0;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _accountNumberController.dispose();
    _mobilePaymentNumberController.dispose();
    _addressReceiverNameController.dispose();
    _addressPhoneNumberController.dispose();
    _addressFullAddressController.dispose();
    _addressCityController.dispose();
    _addressPostalCodeController.dispose();
    super.dispose();
  }

  // Fungsi untuk menambah atau memperbarui alamat
  void _addOrUpdateAddress() {
    if (_addressFormKey.currentState!.validate()) {
      _addressFormKey.currentState!.save();
      setState(() {
        if (_editingAddress == null) {
          // Tambah alamat baru
          _userAddresses.add(Address(
            id: DateTime.now().toIso8601String(), // ID unik sementara
            receiverName: _addressReceiverNameController.text,
            phoneNumber: _addressPhoneNumberController.text,
            fullAddress: _addressFullAddressController.text,
            city: _addressCityController.text,
            postalCode: _addressPostalCodeController.text,
          ));
        } else {
          // Update alamat yang sudah ada
          final index = _userAddresses.indexWhere((addr) => addr.id == _editingAddress!.id);
          if (index != -1) {
            _userAddresses[index] = Address(
              id: _editingAddress!.id,
              receiverName: _addressReceiverNameController.text,
              phoneNumber: _addressPhoneNumberController.text,
              fullAddress: _addressFullAddressController.text,
              city: _addressCityController.text,
              postalCode: _addressPostalCodeController.text,
            );
          }
          _editingAddress = null; // Selesai mengedit
        }
        _addressFormKey.currentState!.reset(); // Reset form
        _clearAddressControllers(); // Bersihkan controller form alamat
        Navigator.of(context).pop(); // Tutup dialog
      });
    }
  }


  void _deleteAddress(String addressId) {
    setState(() {
      _userAddresses.removeWhere((addr) => addr.id == addressId);
      if (_selectedAddress != null && _selectedAddress!.id == addressId) {
        _selectedAddress = null; // Jika alamat yang dihapus adalah yang terpilih, set null
      }
    });
  }

  // Fungsi untuk membersihkan controller form alamat
  void _clearAddressControllers() {
    _addressReceiverNameController.clear();
    _addressPhoneNumberController.clear();
    _addressFullAddressController.clear();
    _addressCityController.clear();
    _addressPostalCodeController.clear();
  }

  // Fungsi untuk menampilkan dialog form tambah/edit alamat
  void _showAddressFormDialog({Address? addressToEdit}) {
    if (addressToEdit != null) {
      _editingAddress = addressToEdit;
      _addressReceiverNameController.text = addressToEdit.receiverName;
      _addressPhoneNumberController.text = addressToEdit.phoneNumber;
      _addressFullAddressController.text = addressToEdit.fullAddress;
      _addressCityController.text = addressToEdit.city;
      _addressPostalCodeController.text = addressToEdit.postalCode;
    } else {
      _editingAddress = null;
      _clearAddressControllers();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(addressToEdit == null ? 'Tambah Alamat Baru' : 'Edit Alamat'),
        content: SingleChildScrollView(
          child: Form(
            key: _addressFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _addressReceiverNameController,
                  decoration: const InputDecoration(labelText: 'Nama Penerima'),
                  validator: (value) => value!.isEmpty ? 'Harap masukkan nama.' : null,
                ),
                TextFormField(
                  controller: _addressPhoneNumberController,
                  decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'Harap masukkan nomor telepon.' : null,
                ),
                TextFormField(
                  controller: _addressFullAddressController,
                  decoration: const InputDecoration(labelText: 'Alamat Lengkap'),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? 'Harap masukkan alamat lengkap.' : null,
                ),
                TextFormField(
                  controller: _addressCityController,
                  decoration: const InputDecoration(labelText: 'Kota/Kabupaten'),
                  validator: (value) => value!.isEmpty ? 'Harap masukkan kota/kabupaten.' : null,
                ),
                TextFormField(
                  controller: _addressPostalCodeController,
                  decoration: const InputDecoration(labelText: 'Kode Pos'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Harap masukkan kode pos.' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearAddressControllers();
              _editingAddress = null;
              Navigator.of(ctx).pop();
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: _addOrUpdateAddress,
            child: Text(addressToEdit == null ? 'Tambah' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  // Fungsi utama untuk menempatkan pesanan
  void _placeOrder() async {
    // Validasi form utama
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validasi alamat pengiriman harus dipilih
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih atau tambahkan alamat pengiriman.')),
      );
      return;
    }

    // Validasi opsi pengiriman harus dipilih
    if (_selectedShippingOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih opsi pengiriman.')),
      );
      return;
    }

    // Validasi kategori pembayaran harus dipilih
    if (_selectedPaymentMethodCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih kategori metode pembayaran (Bank atau Mobile Payment).')),
      );
      return;
    }

    // Validasi detail pembayaran bank jika dipilih
    if (_selectedPaymentMethodCategory == 'bank') {
      if (_selectedBank == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap pilih bank Anda.')),
        );
        return;
      }
      if (_accountNumberController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap masukkan nomor rekening Anda.')),
        );
        return;
      }
    }

    // Validasi detail pembayaran mobile jika dipilih
    if (_selectedPaymentMethodCategory == 'mobile') {
      if (_selectedMobilePay == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap pilih metode pembayaran mobile Anda.')),
        );
        return;
      }
      if (_mobilePaymentNumberController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Harap masukkan nomor ${_selectedMobilePay!} Anda.')),
        );
        return;
      }
    }

    setState(() {
      _isProcessingOrder = true; // Set status sedang memproses
    });

    // Simulasi waktu pemrosesan pesanan
    await Future.delayed(const Duration(seconds: 2));

    final cart = Provider.of<CartProvider>(context, listen: false);
    final totalAmountWithoutShipping = cart.totalAmount;
    final totalAmountWithShipping = totalAmountWithoutShipping + _currentShippingCost;
    final orderNotes = _notesController.text;
    final userAccountNumber = _accountNumberController.text;
    final userMobilePaymentNumber = _mobilePaymentNumberController.text;

    // Menyiapkan detail pembayaran untuk ditampilkan
    String paymentDetail = '';
    if (_selectedPaymentMethodCategory == 'bank') {
      paymentDetail = 'Transfer Bank: ${_selectedBank!} (No. Rek: $userAccountNumber)';
    } else if (_selectedPaymentMethodCategory == 'mobile') {
      paymentDetail = 'Mobile Payment: ${_selectedMobilePay!} (No. Pembayaran: $userMobilePaymentNumber)';
    }

    cart.clearCart(); // Kosongkan keranjang setelah pesanan diproses

    setState(() {
      _isProcessingOrder = false; // Selesai memproses
    });

    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2);

    // Menampilkan dialog konfirmasi pesanan yang sudah diperbarui
    showDialog(
      context: context,
      barrierDismissible: false, // Pengguna harus tap OK untuk menutup
      builder: (ctx) => AlertDialog(
        // Menghapus title bawaan AlertDialog dan mengatur custom content
        contentPadding: EdgeInsets.zero, // Hapus padding default
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        // Bungkus seluruh konten dengan SingleChildScrollView agar bisa digulir
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Penting agar Column tidak mencoba memenuhi seluruh ruang
            children: [
              // Header Dialog: Pesanan Berhasil
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Text(
                      'Pesanan Berhasil Ditempatkan!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Detail Pesanan Utama
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Terima kasih atas pesanan Anda di Toko Olahraga. Detail pesanan Anda adalah:',
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    
                    // Ringkasan Pembayaran
                    _buildSectionTitle('Ringkasan Pembayaran'),
                    _buildDetailRow('Total Pembayaran', currencyFormatter.format(totalAmountWithShipping), isBold: true),
                    _buildDetailRow('Metode Pembayaran', paymentDetail),
                    
                    const Divider(height: 30, thickness: 1),

                    // Ringkasan Pengiriman
                    _buildSectionTitle('Detail Pengiriman'),
                    _buildDetailRow('Opsi Pengiriman', '${_selectedShippingOption!} (${currencyFormatter.format(_currentShippingCost)})'),
                    if (_shippingEstimate.isNotEmpty)
                      _buildDetailRow('Estimasi Tiba', _shippingEstimate, isBold: true),
                    
                    const SizedBox(height: 10),
                    const Text('Alamat Pengiriman:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                    Text(_selectedAddress!.receiverName, style: const TextStyle(fontSize: 14)),
                    Text(_selectedAddress!.displayAddress, style: const TextStyle(fontSize: 14)),
                    
                    if (orderNotes.isNotEmpty) ...[
                      const Divider(height: 30, thickness: 1),
                      _buildSectionTitle('Catatan Tambahan'),
                      Text(orderNotes, style: const TextStyle(fontSize: 14)),
                    ],

                    const Divider(height: 30, thickness: 1),

                    // Instruksi Pembayaran (tergantung metode)
                    if (_selectedPaymentMethodCategory == 'bank')
                      _buildBankPaymentInstructions(
                        _selectedBank!, 
                        userAccountNumber, 
                        Theme.of(context).primaryColor, 
                        currencyFormatter
                      )
                    else if (_selectedPaymentMethodCategory == 'mobile')
                      _buildMobilePaymentInstructions(
                        _selectedMobilePay!, 
                        userMobilePaymentNumber, 
                        Theme.of(context).primaryColor, 
                        currencyFormatter
                      ),
                    
                    const SizedBox(height: 20),
                    const Text(
                      'Anda akan menerima email konfirmasi pesanan dengan detail lengkap.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              // Tombol OK di bagian bawah dialog
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(); // Tutup dialog
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false, // Bersihkan semua rute dan kembali ke Home
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Selesai', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Methods untuk Tampilan Dialog ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? Theme.of(context).primaryColor : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for Bank Payment Instructions section
  Widget _buildBankPaymentInstructions(String bankName, String userAccNum, Color primaryColor, NumberFormat formatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Instruksi Pembayaran Bank'),
        const Text('Silakan lakukan transfer ke rekening berikut:', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Bank Tujuan', bankName, icon: Icons.account_balance),
              _buildInfoRow('Nomor Rekening', '54770100313123', icon: Icons.credit_card),
              _buildInfoRow('Atas Nama', 'Toko Olahraga', icon: Icons.person),
              _buildInfoRow('Kode Transfer', '1234', icon: Icons.vpn_key),
            ],
          ),
        ),
        const SizedBox(height: 15),
        const Text('Nomor rekening Anda yang dimasukkan:', style: TextStyle(fontSize: 14)),
        Text(userAccNum, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        const Text('Mohon lakukan konfirmasi pembayaran setelah transfer berhasil.', style: TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  // Helper method for Mobile Payment Instructions section
  Widget _buildMobilePaymentInstructions(String mobilePayName, String userMobileNum, Color primaryColor, NumberFormat formatter) {
    // Definisi path gambar QR code. Pastikan nama file Anda 'qr_pembayaran.jpg' atau 'qr_pembayaran.png'
    // PENTING: SESUAIKAN NAMA FILE DAN PATH INI DENGAN YANG BENAR DI PROYEK ANDA
    const String qrImagePath = 'assets/images/qr_pembayaran.png'; // <<< SESUAIKAN DENGAN NAMA FILE DAN EKSTENSI YANG TEPAT!

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Instruksi Pembayaran Mobile Payment'),
        Text('Silakan lakukan pembayaran melalui aplikasi $mobilePayName.', style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Aplikasi', mobilePayName, icon: Icons.phone_android),
              _buildInfoRow('ID/No. Telepon', '08234324179', icon: Icons.phone), // Sesuaikan nomor ini
              _buildInfoRow('Atas Nama', 'Toko Olahraga', icon: Icons.person),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    const Text('Scan QR Code ini untuk Pembayaran:', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      width: 180, // Sesuaikan ukuran gambar QR
                      height: 180, // Sesuaikan ukuran gambar QR
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white, // Memberi latar putih pada Container gambar
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // >>> PENGGUNAAN GAMBAR QR DARI ASET DENGAN BoxFit.contain <<<
                      child: Image.asset(
                        qrImagePath, // Menggunakan variabel path gambar QR
                        fit: BoxFit.contain, // Menggunakan BoxFit.contain agar seluruh gambar terlihat
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading QR image: $error');
                          // Mengembalikan SizedBox.shrink() agar tidak ada pengganti visual jika gambar tidak ditemukan
                          return const SizedBox.shrink(); // Mengembalikan ini sesuai permintaan Anda
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        const Text('Nomor pembayaran Anda yang dimasukkan:', style: TextStyle(fontSize: 14)),
        Text(userMobileNum, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        const Text('Mohon lakukan konfirmasi pembayaran setelah selesai.', style: TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  // Generic helper for info rows in instructions (digunakan di dalam _buildBankPaymentInstructions dan _buildMobilePaymentInstructions)
  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.black54),
            const SizedBox(width: 8),
          ],
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2);
    final totalAmountWithoutShipping = cart.totalAmount;
    final totalAmountWithShipping = totalAmountWithoutShipping + _currentShippingCost;

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
                    // --- Ringkasan Pesanan ---
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
                                  Text(currencyFormatter.format(item.price * item.quantity),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )).toList(),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal Produk',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                                Text(
                                  currencyFormatter.format(totalAmountWithoutShipping),
                                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Biaya Pengiriman',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                                Text(
                                  currencyFormatter.format(_currentShippingCost),
                                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                            if (_shippingEstimate.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Estimasi Tiba',
                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                    Text(
                                      _shippingEstimate,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Pembayaran',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  currencyFormatter.format(totalAmountWithShipping),
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

                    // --- Bagian Alamat Pengiriman ---
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Alamat Pengiriman',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_location_alt),
                                  onPressed: () => _showAddressFormDialog(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (_userAddresses.isEmpty)
                              const Text('Belum ada alamat tersimpan. Silakan tambahkan alamat baru.', style: TextStyle(color: Colors.grey))
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _userAddresses.length,
                                itemBuilder: (ctx, index) {
                                  final address = _userAddresses[index];
                                  return RadioListTile<Address>(
                                    title: Text(address.receiverName),
                                    subtitle: Text(address.displayAddress, maxLines: 2, overflow: TextOverflow.ellipsis,),
                                    value: address,
                                    groupValue: _selectedAddress,
                                    onChanged: (Address? value) {
                                      setState(() {
                                        _selectedAddress = value;
                                      });
                                    },
                                    secondary: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          onPressed: () => _showAddressFormDialog(addressToEdit: address),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Hapus Alamat?'),
                                                content: const Text('Anda yakin ingin menghapus alamat ini?'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
                                                  ElevatedButton(onPressed: () {
                                                    _deleteAddress(address.id);
                                                    Navigator.of(ctx).pop();
                                                  }, child: const Text('Hapus')),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            if (_selectedAddress == null && _userAddresses.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('Harap pilih alamat pengiriman.', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Bagian Opsi Pengiriman ---
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Opsi Pengiriman',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            ..._shippingCosts.keys.map((option) {
                              return RadioListTile<String>(
                                title: Text(option),
                                subtitle: Text('${currencyFormatter.format(_shippingCosts[option])} (${_deliveryEstimates[option]})'),
                                value: option,
                                groupValue: _selectedShippingOption,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedShippingOption = value;
                                    _shippingEstimate = _deliveryEstimates[value!] ?? '';
                                  });
                                },
                              );
                            }).toList(),
                            if (_selectedShippingOption == null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('Harap pilih opsi pengiriman.', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Bagian Catatan Pesanan ---
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

                    // --- Bagian Metode Pembayaran ---
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
                                  _selectedMobilePay = null;
                                  _mobilePaymentNumberController.clear();
                                });
                              },
                            ),
                            if (_selectedPaymentMethodCategory == 'bank')
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0, right: 8.0, bottom: 8.0),
                                child: Column(
                                  children: [
                                    DropdownButtonFormField<String>(
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
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: _accountNumberController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nomor Rekening Anda',
                                        hintText: 'Masukkan nomor rekening Anda',
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (_selectedPaymentMethodCategory == 'bank' && (value == null || value.isEmpty)) {
                                          return 'Harap masukkan nomor rekening Anda.';
                                        }
                                        if (_selectedPaymentMethodCategory == 'bank' && !RegExp(r'^[0-9]+$').hasMatch(value!)) {
                                          return 'Nomor rekening hanya boleh angka.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
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
                                  _selectedBank = null;
                                  _accountNumberController.clear();
                                });
                              },
                            ),
                            if (_selectedPaymentMethodCategory == 'mobile')
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0, right: 8.0, bottom: 8.0),
                                child: Column(
                                  children: [
                                    DropdownButtonFormField<String>(
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
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: _mobilePaymentNumberController,
                                      decoration: InputDecoration(
                                        labelText: 'Nomor ${_selectedMobilePay ?? 'Mobile Payment'} Anda',
                                        hintText: 'Masukkan nomor telepon/ID Anda',
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (_selectedPaymentMethodCategory == 'mobile' && (value == null || value.isEmpty)) {
                                          return 'Harap masukkan nomor pembayaran Anda.';
                                        }
                                        if (_selectedMobilePay == 'Dana' || _selectedMobilePay == 'GoPay' || _selectedMobilePay == 'OVO' || _selectedMobilePay == 'LinkAja' || _selectedMobilePay == 'ShopeePay') {
                                          if (!RegExp(r'^[0-9]+$').hasMatch(value!)) {
                                            return 'Nomor pembayaran hanya boleh angka.';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
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