import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/components/buttons.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:itelec_quiz_one/main.dart';
import 'package:itelec_quiz_one/pages/admin/add_edit_products.dart';
import 'package:itelec_quiz_one/pages/catalog_page.dart';
import 'package:itelec_quiz_one/pages/sample_catalog.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  _ManageProductsPageState createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  void _deleteProduct(String id) async {
    await _productsCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Manage Products",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFE0B6),
      ),
      home: Scaffold(
        appBar: AppBarWithMenuAndTitle(title: "Manage Products"),
        drawer: AdminDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Title and Add Product Button
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Space between title and button
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Align items vertically
                children: [
                  // Title
                  Flexible(
                    child: Text(
                      "Products",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF462521),
                      ),
                      overflow: TextOverflow
                          .ellipsis, // Prevent overflow for long titles
                    ),
                  ),

                  // Add Product Button
                  GradientButton(
                    text: "Add a Product",
                    onPressed: () {
                      print("Add a Product button pressed");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEditProductPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Product List Section
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _productsCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No products found.'));
                    }
                    final products = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final productId = product.id;

                        // Use the `get` method with a default value to handle missing fields
                        final productName =
                            product.data().toString().contains('name')
                                ? product.get('name') ?? 'Unnamed Product'
                                : 'Unnamed Product';
                        final productPrice =
                            product.data().toString().contains('price')
                                ? product.get('price') ?? 0.0
                                : 0.0;
                        final productDescription =
                            product.data().toString().contains('description')
                                ? product.get('description') ?? ''
                                : '';
                        final productImagePath =
                            product.data().toString().contains('image_path')
                                ? product.get('image_path')
                                : null;

                        final passedProduct = {
                          'id': productId,
                          'name': productName,
                          'price': productPrice,
                          'description': productDescription,
                          'image_path': productImagePath,
                        };

                        return ListTile(
                          title: Text(productName),
                          subtitle: Text(
                              'Price: ₱${productPrice.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Color(0xFFCA2E55)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddEditProductPage(
                                          isEditing: true,
                                          product: passedProduct),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Color(0xFFCA2E55)),
                                onPressed: () => _deleteProduct(productId),
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
      ),
    );
  }
}
