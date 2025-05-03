import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donut_stop/components/user_drawers.dart';
import 'package:donut_stop/main.dart';
import 'package:donut_stop/pages/catalog_page.dart';
import 'package:donut_stop/pages/sample_catalog.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  _ProductManagementPageState createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  void _createProduct() async {
    if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      await _productsCollection.add({
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
      });
      _nameController.clear();
      _priceController.clear();
    }
  }

  void _updateProduct(String id, String newName, double newPrice) async {
    await _productsCollection
        .doc(id)
        .update({'name': newName, 'price': newPrice});
  }

  void _deleteProduct(String id) async {
    await _productsCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Product Management Page",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFE0B6),
      ),
      home: Scaffold(
        appBar: AppBarWithMenuAndTitle(title: "Product Management"),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const CatalogPageTitleContainer(),
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Product Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _createProduct,
                      child: const Text(
                        'Add Product',
                        style: TextStyle(
                            color: Colors.white), // Changed font color to white
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC345E),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _productsCollection.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFDC345E)),
                                backgroundColor: Color(0xFFFF7171),
                                strokeWidth: 5.0,
                              ),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text(
                              'No products found.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFC7A889),
                              ),
                            ));
                          }
                          final products = snapshot.data!.docs;
                          return ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final productName = product['name'];
                              final productPrice = product['price'];
                              return ListTile(
                                title: Text(productName),
                                subtitle: Text(
                                    'Price: ₱${productPrice.toStringAsFixed(2)}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () {
                                        _nameController.text = productName;
                                        _priceController.text =
                                            productPrice.toString();
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Update Product'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller: _nameController,
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText: 'New Name',
                                                    ),
                                                  ),
                                                  TextField(
                                                    controller:
                                                        _priceController,
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText: 'New Price',
                                                    ),
                                                    keyboardType:
                                                        TextInputType.number,
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    _updateProduct(
                                                      product.id,
                                                      _nameController.text,
                                                      double.tryParse(
                                                              _priceController
                                                                  .text) ??
                                                          0.0,
                                                    );
                                                    _nameController.clear();
                                                    _priceController.clear();
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Update'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    _nameController.clear();
                                                    _priceController.clear();
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _deleteProduct(product.id),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        drawer: UserDrawer(),
      ),
    );
  }
}
