import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/pages/cart_page.dart';
import 'package:itelec_quiz_one/pages/catalog_page.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';

class ProductPage extends StatefulWidget {
  final String productId; // Add productId parameter
  final String image;
  final String title;
  final String description;
  final String oldPrice;
  final String newPrice;
  final bool isFavInitial;

  const ProductPage({
    required this.productId, // Make productId required
    this.image = "assets/front_donut/fdonut5.png",
    this.title = "Strawberry Sprimkle",
    this.description =
        "Strawberry Sprinkles doni is a treat you can't resist! With a soft, fluffy base coated in rich strawberry glaze and topped with colorful ssprinkle, every bite is a perfect  balance of sweetness.",
    this.oldPrice = "₱90",
    this.newPrice = "₱76",
    this.isFavInitial = false,
    super.key,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  bool isFav = false;
  int quantity = 1;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  Map<String, dynamic> userData = {};
  String userId = '';

  @override
  void initState() {
    super.initState();
    isFav = widget.isFavInitial;
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    try {
      final data =
          await fetchAuthenticatedUserData(auth, usersCollection, context);
      if (data != null) {
        setState(() {
          userData = data;
          userId = data["id"];
          final userFavorites = userData['favorites'] ?? [];
          isFav =
              userFavorites.contains(widget.productId) || widget.isFavInitial;
        });
      }
    } catch (e) {
      print("Error initializing user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch user data."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> addToCart(String userId, String productId, int quantity) async {
    try {
      // Reference to the user's cart subcollection
      CollectionReference cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart');

      // Check if the product already exists in the cart
      QuerySnapshot existingProduct =
          await cartRef.where('product_id', isEqualTo: productId).get();

      if (existingProduct.docs.isNotEmpty) {
        // If the product already exists, update the quantity
        DocumentReference productDoc = existingProduct.docs.first.reference;
        int currentQuantity = existingProduct.docs.first['quantity'];
        await productDoc.update({'quantity': currentQuantity + quantity});
        print("Product quantity updated in the cart.");
      } else {
        // If the product does not exist, add it to the cart
        await cartRef.add({
          'product_id': productId,
          'quantity': quantity,
        });
        print("Product added to the cart.");
        toastification.show(
          context: context,
          title: Text('Product added to cart'),
          description:
              Text('$quantity ${widget.title} has been added to your cart.'),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      print("Error adding product to cart: $e");
      toastification.show(
        context: context,
        title: Text('Error adding to cart'),
        description: Text('Failed to add product to cart. Please try again.'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> toggleFavoriteStatus(String userId, String productId) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      List<dynamic> favorites = userData['favorites'] ?? [];

      if (favorites.contains(productId)) {
        // Remove from favorites
        favorites.remove(productId);
        await userRef.update({'favorites': favorites});
        print("Product removed from favorites.");
        setState(() {
          isFav = false;
        });
        toastification.show(
          context: context,
          title: Text('Product removed from favorites'),
          description:
              Text('${widget.title} has been removed from your favorites.'),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 4),
        );
      } else {
        // Add to favorites
        favorites.add(productId);
        await userRef.update({'favorites': favorites});
        print("Product added to favorites.");
        setState(() {
          isFav = true;
        });
        toastification.show(
          context: context,
          title: Text('Product added to favorites'),
          description:
              Text('${widget.title} has been added to your favorites.'),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      print("Error toggling favorite status: $e");
      toastification.show(
        context: context,
        title: Text('Error toggling favorite status'),
        description:
            Text('Failed to update favorite status. Please try again.'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Product Page",
      debugShowCheckedModeBanner: false, // Remove debug ribbon
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFE0B6),
        fontFamily: 'Inter', // Apply Inter font
      ),
      home: Scaffold(
        backgroundColor: Color(0xFFFFE0B6), // Background color
        appBar: AppBarWithBackAndTitle(
          backgroundColor: Colors.transparent,
          onBackPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CatalogPage(),
              ),
            );
          },
          trailingWidget: Container(
            padding: EdgeInsets.only(left: 10),
            child: IconButton(
              icon: Icon(Icons.shopping_cart, color: Color(0xFF2F090B)),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => CartPage())),
            ),
          ),
        ),
        body: Column(
          children: [
            // Donut Image Section
            Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: widget.image.isNotEmpty &&
                        widget.image.startsWith('data:image/')
                    ? Image.memory(
                        base64Decode(widget.image.split(',').last),
                        fit: BoxFit.contain,
                        width: 330,
                        height: 330,
                      )
                    : Image.asset(
                        width: 330,
                        height: 330,
                        widget.image.isNotEmpty
                            ? widget.image
                            : 'assets/front_donut/fdonut1.png',
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            SizedBox(height: 20),

            // Product Details Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Center(
                  // Ensure maxWidth applies correctly
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 800),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Favorite Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF462521),
                                ),
                                softWrap: true,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                size: 30,
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: Color(0xFFCA2E55),
                              ),
                              onPressed: () async {
                                await toggleFavoriteStatus(
                                    userId, widget.productId);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 30),

                        // About Donut Description
                        Text(
                          "About Donut",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        SizedBox(height: 20),

                        // Quantity Selector
                        SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 20,
                              runSpacing: 5,
                              children: [
                                Text(
                                  "Quantity",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                QuantitySelector(
                                  quantity: quantity,
                                  onQuantityChanged: (newQuantity) {
                                    setState(() {
                                      quantity = newQuantity;
                                    });
                                  },
                                ),
                              ],
                            )),
                        SizedBox(height: 20),

                        // Price & Add to Cart Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 30,
                            runSpacing: 30,
                            children: [
                              Text(
                                widget.newPrice,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                width: double
                                    .infinity, // Take full width if wrapped
                                constraints: BoxConstraints(
                                    maxWidth: 200), // Limit max width
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFF7171),
                                      Color(0xFFDC345E)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      // Fetch authenticated user data
                                      final auth = FirebaseAuth.instance;
                                      final userId = auth.currentUser?.uid;

                                      if (userId == null) {
                                        throw Exception("User not logged in.");
                                      }

                                      // Use the quantity from the QuantitySelector
                                      await addToCart(
                                          userId, widget.productId, quantity);
                                    } catch (e) {
                                      print("Error adding to cart: $e");
                                      toastification.show(
                                        context: context,
                                        title: Text('Error adding to cart'),
                                        description: Text(
                                            'Failed to add product to cart. Please try again.'),
                                        type: ToastificationType.error,
                                        autoCloseDuration:
                                            const Duration(seconds: 4),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 25),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Add to Cart",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final Function(int) onQuantityChanged;

  QuantitySelector({required this.quantity, required this.onQuantityChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.remove, color: Colors.black),
              onPressed: () {
                if (quantity > 1) {
                  onQuantityChanged(quantity - 1); // Decrease quantity
                }
              },
            ),
          ),
          SizedBox(width: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "$quantity", // Display current quantity
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter'),
            ),
          ),
          SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF7171), Color(0xFFDC345E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                onQuantityChanged(quantity + 1); // Increase quantity
              },
            ),
          ),
        ],
      ),
    );
  }
}
