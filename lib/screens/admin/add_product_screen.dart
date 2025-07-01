// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:toko_olahraga/services/admin_service.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/providers/product_provider.dart';
import 'package:toko_olahraga/models/product.dart'; // Import model Product

class AddProductScreen extends StatefulWidget {
  static const routeName = '/add-product';

  // Tambahkan parameter opsional untuk produk yang akan diedit
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();

  bool _isLoading = false;

  String? _selectedCategory;

  final AdminService _adminService = AdminService();

  // Variabel untuk menyimpan apakah ini mode edit atau tambah
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _isEditing = true;
      // Isi controller dengan data produk yang akan diedit
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _imageUrlController.text = widget.product!.imageUrl;
      _selectedCategory = widget.product!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Validasi URL gambar
    if (_imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap masukkan URL gambar produk.')),
      );
      return;
    }
    if ((!_imageUrlController.text.startsWith('http') &&
            !_imageUrlController.text.startsWith('https')) ||
        (!_imageUrlController.text.endsWith('.png') &&
            !_imageUrlController.text.endsWith('.jpg') &&
            !_imageUrlController.text.endsWith('.jpeg'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Harap masukkan URL gambar yang valid (.png, .jpg, .jpeg).')),
      );
      return;
    }

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih kategori produk.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEditing) {
        // Logika untuk mengedit produk
        await _adminService.updateProductInFirestore(
          id: widget.product!.id, // Gunakan ID produk yang ada
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          imageUrl: _imageUrlController.text,
          category: _selectedCategory!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil diperbarui!')),
        );
      } else {
        // Logika untuk menambahkan produk baru
        await _adminService.addProductToFirestore(
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          imageUrl: _imageUrlController.text,
          category: _selectedCategory!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan!')),
        );
      }

      // Setelah berhasil menambahkan/memperbarui, minta ProductsProvider untuk memuat ulang data
      // AKTIFKAN KEMBALI BARIS INI
      await Provider.of<ProductsProvider>(context, listen: false).fetchAndSetProducts();

      // Teruskan nilai 'true' saat pop untuk menunjukkan bahwa perubahan telah dilakukan
      Navigator.of(context).pop(true); // Kembali ke layar sebelumnya dengan hasil true
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan produk: $error')),
      );
      debugPrint('Error saving product in AddProductScreen: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Produk' : 'Tambah Produk Baru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProduct,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Produk'),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Harap masukkan nama produk.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Harap masukkan deskripsi.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Harga'),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Harap masukkan harga.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Harga harus berupa angka.';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Harga harus lebih besar dari 0.';
                        }
                        return null;
                      },
                    ),
                    // Dropdown untuk Kategori
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      value: _selectedCategory,
                      hint: const Text('Pilih Kategori'),
                      items: <String>[
                        'PeralatanGym',
                        'Renang',
                        'Sepatu',
                        'Aksesoris',
                        'Bola',
                        'Raket',
                        'Alat Pelindung',
                        'Supplement',
                        'Obat',
                        'Buku',
                        'Lainnya',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap pilih kategori.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(labelText: 'URL Gambar Produk'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap masukkan URL gambar produk.';
                        }
                        if (!value.startsWith('http') && !value.startsWith('https')) {
                          return 'Harap masukkan URL yang valid (dimulai dengan http/https).';
                        }
                        if (!value.endsWith('.png') && !value.endsWith('.jpg') && !value.endsWith('.jpeg')) {
                          return 'Harap masukkan URL gambar yang valid (.png, .jpg, .jpeg).';
                        }
                        return null;
                      },
                      onChanged: (_) {
                        setState(() {}); // Memperbarui UI saat URL gambar berubah
                      },
                    ),
                    const SizedBox(height: 10),
                    // Tampilkan pratinjau gambar dari URL
                    _imageUrlController.text.isNotEmpty
                        ? Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Text(
                                    'Gagal memuat gambar',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                );
                              },
                            ),
                          )
                        : const SizedBox.shrink(), // Sembunyikan jika URL kosong

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProduct,
                      child: Text(_isEditing ? 'Simpan Perubahan' : 'Tambah Produk'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}