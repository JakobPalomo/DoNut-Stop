import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:itelec_quiz_one/pages/checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int itemCount = 1;
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      String userId = "O5XpBhLgOGTHaLn5Oub9hRrwEhq1";

      // Fetch cart items from the user's cart collection
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
        int quantity = (cartDoc.data() as Map<String, dynamic>)['quantity'] ?? 1;
        // Fetch product details from the donuts collection
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

      setState(() {
        cartItems = items;
        totalAmount = total;
      });
    } catch (e) {
      print("Error fetching cart items: $e");
    }
  }

  Future<void> updateCartItemQuantity(String userId, String cartId, int newQuantity) async {
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
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20, top: 20),
              child: Text(
                "My Cart",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF462521),
                ),
                softWrap: true,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    Container(
                      width: 60,
                      height: 60,
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(item['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF462521),
                              ),
                            ),
                            Text(
                              "₱${item['price']}", // Product price
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF462521),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xFFFF7171),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: IconButton(
                                  icon: Icon(Icons.remove,
                                      color: Color(0xFFFF7171), size: 12),
                                  onPressed: () async {
                                  if (item['quantity'] > 1) {
                                    setState(() {
                                      item['quantity']--; // Decrease quantity in the UI
                                      totalAmount -= item['price']; // Update total amount
                                    });
                                    print("Updating cart_id: ${item['cart_id']} with quantity: ${item['quantity']}");
                                    await updateCartItemQuantity(
                                      "O5XpBhLgOGTHaLn5Oub9hRrwEhq1", // Replace with dynamic userId if needed
                                      item['cart_id'], // Use cart_id instead of product_id
                                      item['quantity'], // Update the new quantity
                                    );
                                  }
                                },
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                            "${item['quantity']}", // Display the updated quantity
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF462521),
                            ),
                          ),
                            SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF7171),
                                    Color(0xFFDC345E)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: IconButton(
                                  icon: Icon(Icons.add,
                                      color: Color(0xFF462521), size: 12),
                                  onPressed: () async {
                                  setState(() {
                                    item['quantity']++; // Increase quantity in the UI
                                    totalAmount += item['price']; // Update total amount
                                  });
                                  print("Updating cart_id: ${item['cart_id']} with quantity: ${item['quantity']}");
                                  await updateCartItemQuantity(
                                    "O5XpBhLgOGTHaLn5Oub9hRrwEhq1", // Replace with dynamic userId if needed
                                    item['cart_id'], // Use cart_id instead of product_id
                                    item['quantity'], // Update the new quantity
                                  );
                                },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Total and Checkout Button
            Container(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Total Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total",
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
                    ],
                  ),
                  // Checkout Button
                  ElevatedButton(
                    onPressed: () {
                      // Handle checkout logic here
                      print("Proceeding to checkout...");
                        Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CheckoutPage()),
                    );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      backgroundColor: Color(0xFFDC345E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Checkout",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}