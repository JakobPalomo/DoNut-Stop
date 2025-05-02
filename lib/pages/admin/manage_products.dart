import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/components/buttons.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:itelec_quiz_one/pages/admin/add_edit_products.dart';
import 'dart:convert'; // For Base64 encoding
import 'package:toastification/toastification.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  _ManageProductsPageState createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  final ScrollController _scrollController = ScrollController();
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  void _deleteProduct(String id) async {
    await _productsCollection.doc(id).delete();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Sliver for Title and Add Product Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                        overflow: TextOverflow.ellipsis,
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
              ),
            ),

            // Sliver for Product List Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: StreamBuilder<QuerySnapshot>(
                stream: _productsCollection
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverFillRemaining(
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFDC345E)),
                          backgroundColor: Color(0xFFFF7171),
                          strokeWidth: 5.0,
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return SliverFillRemaining(
                      child: const Center(
                          child: Text(
                        'No products found.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC7A889),
                        ),
                      )),
                    );
                  }
                  final products = snapshot.data!.docs;

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
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
                            product.data().toString().contains('image')
                                ? product.get('image')
                                : null;

                        final passedProduct = {
                          'id': productId,
                          'name': productName,
                          'price': productPrice,
                          'description': productDescription,
                          'image': productImagePath,
                        };

                        return Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFFFEEE1),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Leading Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: productImagePath != null &&
                                          productImagePath.isNotEmpty &&
                                          productImagePath
                                              .startsWith('data:image/')
                                      ? Image.memory(
                                          base64Decode(
                                              productImagePath.split(',').last),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          productImagePath != null &&
                                                  productImagePath.isNotEmpty
                                              ? productImagePath
                                              : 'assets/front_donut/fdonut1.png',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 15),

                              // Main content (Title, Subtitle)
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF462521),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₱${productPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF462521),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    productDescription != null &&
                                            productDescription.isNotEmpty
                                        ? Text(
                                            productDescription,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Inter',
                                              color: Color(0xFF462521),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),

                              // Trailing buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Color(0xFFCA2E55)),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddEditProductPage(
                                            isEditing: true,
                                            product: passedProduct,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Color(0xFFCA2E55)),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: Colors.white,
                                            titlePadding:
                                                const EdgeInsets.all(0),
                                            actionsAlignment:
                                                MainAxisAlignment.center,
                                            title: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFCA2E55),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              child: const Text(
                                                "Confirm Deletion",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Inter',
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            content: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  20, 15, 20, 5),
                                              child: Text(
                                                "Are you sure you want to delete this product?",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Inter',
                                                ),
                                              ),
                                            ),
                                            actions: [
                                              Wrap(
                                                  alignment:
                                                      WrapAlignment.center,
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  spacing: 10,
                                                  runSpacing: 10,
                                                  children: [
                                                    CustomOutlinedButton(
                                                      text: "Cancel",
                                                      bgColor: Colors.white,
                                                      textColor:
                                                          Color(0xFFCA2E55),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    GradientButton(
                                                      text: "Delete",
                                                      onPressed: () {
                                                        _deleteProduct(
                                                            productId);
                                                        Navigator.of(context)
                                                            .pop();
                                                        toastification.show(
                                                          context: context,
                                                          title: Text(
                                                              'Product deleted'),
                                                          description: Text(
                                                              '$productName has been deleted.'),
                                                          type:
                                                              ToastificationType
                                                                  .success,
                                                          autoCloseDuration:
                                                              const Duration(
                                                                  seconds: 4),
                                                        );
                                                      },
                                                    ),
                                                  ])
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: products.length,
                    ),
                  );
                },
              ),
            ),

            // Silver for Button
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                width: double.infinity,
                alignment: Alignment.center,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    // Back to Top Button
                    CustomOutlinedButton(
                      text: "Back to Top",
                      bgColor: Colors.white,
                      textColor: const Color(0xFFCA2E55),
                      onPressed: () {
                        _scrollController.animateTo(
                          0,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
