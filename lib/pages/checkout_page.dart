import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});  
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int itemCount = 1;
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0.0;
  String fullName = "";
  String userAddress = ""; 
  String selectedPaymentMethod = "Cash on Delivery";
  @override
  void initState() {
    super.initState();
    fetchCartItems();
    fetchUserAddress();
  }
  Future<void> fetchUserAddress() async {
    try {
      String userId = "EVotCwhDcQPJnn43wdypHtHES1M2";

      // Fetch user details from the users collection
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        var userData = userSnapshot.data() as Map<String, dynamic>;
        fullName =
            "${userData['firstName'] ?? "Unknown First Name"} ${userData['lastName'] ?? "Unknown Last Name"}";
        String city = userData['city'] ?? "Unknown City";
        String district = userData['district'] ?? "Unknown District";
        String zip = userData['zip'] ?? "Unknown ZIP";

        setState(() {
          userAddress = "$city, $district, $zip"; // Combine city, district, and zip
        });
      }
    } catch (e) {
      print("Error fetching user address: $e");
    }
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
        String productId =
            (cartDoc.data() as Map<String, dynamic>)['product_id'];
        int quantity = (cartDoc.data() as Map<String, dynamic>)['quantity'] ?? 1; // Get quantity

        // Fetch product details from the donuts collection
        DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        if (productSnapshot.exists) {
          var productData = productSnapshot.data() as Map<String, dynamic>;
          productData['quantity'] = quantity; 
          items.add(productData);

          // Calculate total amount
          total += (productData['price'] ?? 0) * itemCount;
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
      appBar: AppBarWithMenuAndTitle(title: "Items"),
      drawer: UserDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Details
            Container(
              margin: EdgeInsets.only(left: 20, top: 20),
              child: Text(
                fullName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF462521),
                ),
                softWrap: true,
              ),
            ),
            SizedBox(height: 5),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                userAddress,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF462521),
                ),
                softWrap: true,
              ),
            ),
            SizedBox(height: 10),
            // Items Header
            Container(
              margin: EdgeInsets.only(left: 20, top: 20),
              child: Text(
                "Items",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF462521),
                ),
                softWrap: true,
              ),
            ),
            SizedBox(height: 20),
            // Items List
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Donut Image and Details
                      Row(
                        children: [
                          // Donut Image
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
                          // Donut Name and Quantity
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
                                "Quantity",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF462521),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "₱${item['price'].toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF462521),
                            ),
                          ),
                          Text(
                            "${item['quantity']}x",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF462521),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            // Payment Method Section
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Method",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF462521),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "*We don't accept card payments",
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF462521),
                    ),
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: "Cash on Delivery",
                        groupValue: selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMethod = value!;
                          });
                        },
                      ),
                      Text(
                        "Cash on Delivery",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF462521),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: "GCash",
                        groupValue: selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMethod = value!;
                          });
                        },
                      ),
                      Text(
                        "GCash",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF462521),
                        ),
                      ),
                    ],
                  ),
                
                ],
              ),
            ),
            SizedBox(height: 20),
            // Order Summary Section
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF462521),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Order Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order Subtotal",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF462521),
                        ),
                      ),
                      Text(
                        "₱${totalAmount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF462521),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  // Shipping
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Shipping",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF462521),
                        ),
                      ),
                      Text(
                        "₱50.00",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF462521),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  // Payment Method
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Payment Method",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF462521),
                        ),
                      ),
                      Text(
                        selectedPaymentMethod,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF462521),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey),
                  // Order Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order Total",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF462521),
                        ),
                      ),
                      Text(
                        "₱${(totalAmount + 50).toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF462521),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Place Order Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        print("Order placed with $selectedPaymentMethod");
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        backgroundColor: Color(0xFFDC345E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Place Order",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
  );
}
}