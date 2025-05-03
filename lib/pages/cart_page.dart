import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donut_stop/components/buttons.dart';
import 'package:donut_stop/components/user_drawers.dart';
import 'package:donut_stop/pages/catalog_page.dart';
import 'package:donut_stop/pages/checkout_page.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int itemCount = 1;
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0.0;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  Map<String, dynamic> userData = {};
  String userId = '';
  List<Map<String, dynamic>> updateQueue = [];
  bool isProcessingUpdates = false;
  bool isLoading = true; // Initially set to true

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final data =
          await fetchAuthenticatedUserData(auth, usersCollection, context);
      if (data != null) {
        setState(() {
          userData = data;
          userId = data["id"];
        });
        await fetchCartItems(data["id"]);
      }
    } catch (e) {
      print("Error initializing user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch user data."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCartItems(String userId) async {
    try {
      setState(() {
        isLoading = true;
      });

      // Fetch cart items from the user's cart collection

      if (userId.isEmpty) {
        throw Exception("User ID is not initialized.");
      }

      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      List<Map<String, dynamic>> items = [];
      double total = 0.0;

      for (var cartDoc in cartSnapshot.docs) {
        String cartId = cartDoc.id;
        String productId =
            (cartDoc.data() as Map<String, dynamic>)['product_id'];
        int quantity =
            (cartDoc.data() as Map<String, dynamic>)['quantity'] ?? 1;

        // Fetch product details from the products collection
        DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        if (productSnapshot.exists) {
          var productData = productSnapshot.data() as Map<String, dynamic>;
          productData['cart_id'] = cartId;
          productData['quantity'] = quantity;
          productData['subtotal'] = (productData['price'] ?? 0) * quantity;
          items.add(productData);

          // Calculate total amount
          total += productData['subtotal'];
        }
      }

      print("Fetched cart items: $items");
      print("Total amount: $total");
      setState(() {
        cartItems = items;
        totalAmount = total;
      });
    } catch (e) {
      print("Error fetching cart items: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateCartItemQuantity(
      String userId, String cartId, int newQuantity) async {
    try {
      DocumentReference cartItemRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cartId);

      DocumentSnapshot cartItemSnapshot = await cartItemRef.get();

      if (cartItemSnapshot.exists) {
        await cartItemRef.update({'quantity': newQuantity});
        print("Cart item updated: cartId=$cartId, newQuantity=$newQuantity");
      } else {
        print("Cart item with cartId=$cartId does not exist.");
      }
    } catch (e) {
      print("Error updating cart item quantity: $e");
    }
  }

  void queueCartUpdate(String userId, String cartId, int newQuantity) {
    updateQueue.add({
      'userId': userId,
      'cartId': cartId,
      'newQuantity': newQuantity,
    });

    if (!isProcessingUpdates) {
      _processCartUpdates();
    }
  }

  Future<void> _processCartUpdates() async {
    isProcessingUpdates = true;

    while (updateQueue.isNotEmpty) {
      final update = updateQueue.removeAt(0);

      try {
        await updateCartItemQuantity(
          update['userId'],
          update['cartId'],
          update['newQuantity'],
        );
        print(
            "Cart item updated: cartId=${update['cartId']}, newQuantity=${update['newQuantity']}");
      } catch (e) {
        print("Error updating cart item: $e");
      }
    }

    isProcessingUpdates = false;
  }

  // Product Image
  Widget _buildProductImage(Map item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 90,
        height: 90,
        child: item['image'] != null &&
                item['image'].isNotEmpty &&
                item['image'].startsWith('data:image/')
            ? Image.memory(
                base64Decode(item['image'].split(',').last),
                fit: BoxFit.cover,
              )
            : Image.asset(
                item['image'] != null && item['image'].isNotEmpty
                    ? item['image']
                    : 'assets/front_donut/fdonut1.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  // Main content (Product Name, Price)
  Widget _buildNameAndPrice(Map item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['name'] ?? 'Unknown Product',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: Color(0xFF462521),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₱${item['price'].toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 17,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            color: Color(0xFF462521),
          ),
        ),
      ],
    );
  }

  // Quantity Selector
  Widget _buildQuantitySelector(Map item) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black26,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            width: 38,
            height: 38,
            child: IconButton(
              icon: Icon(Icons.remove, color: Colors.black26, size: 20),
              onPressed: () {
                if (item['quantity'] > 1) {
                  setState(() {
                    item['quantity']--;
                    totalAmount -= item['price'];
                  });

                  print(
                      "Queueing update for cart_id: ${item['cart_id']} with quantity: ${item['quantity']}");
                  queueCartUpdate(
                    userId,
                    item['cart_id'],
                    item['quantity'],
                  );
                }
              },
            ),
          ),
        ),
        SizedBox(width: 15),
        Text(
          "${item['quantity']}",
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(width: 15),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7171), Color(0xFFDC345E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            width: 38,
            height: 38,
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.white, size: 20),
              onPressed: () {
                setState(() {
                  item['quantity']++;
                  totalAmount += item['price'];
                });

                print(
                    "Queueing update for cart_id: ${item['cart_id']} with quantity: ${item['quantity']}");
                queueCartUpdate(
                  userId,
                  item['cart_id'],
                  item['quantity'],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Product Page Module",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFE0B6),
        fontFamily: 'Inter',
      ),
      home: Scaffold(
        backgroundColor: Color(0xFFFFE0B6),
        appBar: AppBarWithMenuAndTitle(title: "My Cart"),
        drawer: UserDrawer(),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC345E)),
                  backgroundColor: Color(0xFFFF7171),
                  strokeWidth: 5.0,
                ),
              )
            : Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20, top: 20, bottom: 5),
                    child: Row(
                      children: [
                        Text(
                          "My Cart",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF462521),
                          ),
                          softWrap: true,
                        ),
                        SizedBox(width: 20),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Color(0xFFCA2E55),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${cartItems.length}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            padding: const EdgeInsets.fromLTRB(5, 5, 20, 5),
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Product Image
                                _buildProductImage(item),
                                const SizedBox(width: 15),
                                // Main Content Area
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      bool isSmallScreen =
                                          constraints.maxWidth < 300;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Top Row: Name + Price and Quantity
                                          isSmallScreen
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _buildNameAndPrice(item),
                                                    const SizedBox(height: 8),
                                                    _buildQuantitySelector(
                                                        item),
                                                  ],
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    _buildNameAndPrice(item),
                                                    _buildQuantitySelector(
                                                        item),
                                                  ],
                                                ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ));
                      },
                    ),
                  ),
                  // Total and Checkout Button
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 0,
                      runAlignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(children: [
                          // Total Amount and Shipping Fee
                          Expanded(
                            flex: 1,
                            child: Wrap(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 5,
                              runSpacing: 0,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Wrap(
                                    direction: Axis.horizontal,
                                    alignment: WrapAlignment.start,
                                    spacing: 5,
                                    runSpacing: 0,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        "Subtotal:",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF462521),
                                        ),
                                      ),
                                      Text(
                                        "₱${totalAmount.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF462521),
                                        ),
                                      ),
                                    ]),
                                Wrap(
                                  direction: Axis.horizontal,
                                  alignment: WrapAlignment.start,
                                  spacing: 5,
                                  runSpacing: 0,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      "Shipping:",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF462521),
                                      ),
                                    ),
                                    Text(
                                      "₱30.00",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF462521),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 20),
                          // Checkout Button
                          GradientButton(
                            text: "Checkout",
                            isEnabled: cartItems.isNotEmpty,
                            onPressed: cartItems.isNotEmpty
                                ? () {
                                    print("Proceeding to checkout...");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CheckoutPage()),
                                    );
                                  }
                                : null,
                          )
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
