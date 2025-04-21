import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/components/buttons.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itelec_quiz_one/pages/catalog_page.dart';
import 'package:itelec_quiz_one/pages/my_orders_page.dart';
import 'package:toastification/toastification.dart';

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
  String userContactNo = "";
  String selectedPaymentMethod = "Cash on Delivery";
  bool isLoading = true; // Initially set to true

  final FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  Map<String, dynamic> userData = {};
  String userId = '';

  final List<Map<String, dynamic>> paymentMethods = [
    {"label": "Cash on Delivery", "value": 1},
    {"label": "Credit Card", "value": 2},
  ];

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    try {
      setState(() {
        isLoading = true; // Start loading
      });

      final data =
          await fetchAuthenticatedUserData(auth, usersCollection, context);
      if (data != null) {
        setState(() {
          userData = data;
          userId = data["id"];
        });
        await fetchCartItems(data["id"]);
        fullName = "${data["first_name"]} ${data["last_name"]}";
        userAddress = data["address"];
        userContactNo = data["contact_no"];
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
        isLoading = false; // Stop loading
      });
    }
  }

  Future<void> fetchUserAddress() async {
    try {
      String userId = "O5XpBhLgOGTHaLn5Oub9hRrwEhq1";

      // Fetch the user's location document from the locations subcollection
      QuerySnapshot locationSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('locations')
          .get();

      if (locationSnapshot.docs.isNotEmpty) {
        var locationData =
            locationSnapshot.docs.first.data() as Map<String, dynamic>;

        String stateProvince = locationData['state_province']?.toString() ??
            "Unknown State/Province";
        String cityMunicipality =
            locationData['city_municipality']?.toString() ??
                "Unknown City/Municipality";
        String barangay =
            locationData['barangay']?.toString() ?? "Unknown Barangay";
        String houseNoBuildingStreet =
            locationData['house_no_building_street']?.toString() ??
                "Unknown Address";
        String zip = locationData['zip']?.toString() ?? "Unknown ZIP";

        setState(() {
          userAddress =
              "$houseNoBuildingStreet, $barangay, $cityMunicipality, $stateProvince, $zip";
        });
      } else {
        print("No location data found for userId=$userId");
      }
    } catch (e) {
      print("Error fetching user address: $e");
    }
  }

  Future<void> fetchUserName() async {
    try {
      String userId =
          "EVotCwhDcQPJnn43wdypHtHES1M2"; // Replace with dynamic userId if needed

      // Fetch the user's document from the users collection
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        var userData = userSnapshot.data() as Map<String, dynamic>;

        String firstName =
            userData['first_name']?.toString() ?? "Unknown First Name";
        String lastName =
            userData['last_name']?.toString() ?? "Unknown Last Name";

        setState(() {
          fullName = "$firstName $lastName";
        });
      } else {
        print("No user data found for userId=$userId");
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  Future<void> fetchCartItems(String userId) async {
    try {
      setState(() {
        isLoading = true; // Start loading
      });

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
        String productId =
            (cartDoc.data() as Map<String, dynamic>)['product_id'];
        int quantity =
            (cartDoc.data() as Map<String, dynamic>)['quantity'] ?? 1;

// Fetch product details from the donuts collection
        DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        if (productSnapshot.exists) {
          var productData = productSnapshot.data() as Map<String, dynamic>;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch cart items."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      // Fetch all cart items
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      if (cartSnapshot.docs.isNotEmpty) {
        // Use a WriteBatch to delete all cart items in a single operation
        WriteBatch batch = FirebaseFirestore.instance.batch();

        for (var cartDoc in cartSnapshot.docs) {
          batch.delete(cartDoc.reference);
        }

        // Commit the batch
        await batch.commit();
        print("Cart cleared successfully.");
      } else {
        print("No items found in the cart to delete.");
      }
    } catch (e) {
      print("Error clearing cart: $e");
      throw Exception("Failed to clear cart.");
    }
  }

  Future<void> placeOrder() async {
    try {
      String userId = userData['id']; // Use the dynamic userId
      DateTime now = DateTime.now();

      // Generate the reference number in the desired format
      String formattedDate =
          DateFormat('yyyyMMdd').format(now); // e.g., 20250419
      String formattedTime = DateFormat('HHmm').format(now); // e.g., 0753
      String randomNumber =
          (Random().nextInt(900) + 100).toString(); // Random 3-digit number
      String refNo = "OR$formattedDate$formattedTime$randomNumber";

      double totalPrice = totalAmount + 30; // Add shipping fee
      Timestamp datetimePurchased = Timestamp.now();

      // Extract the zip code as a number
      int zipCode = int.tryParse(userAddress.split(', ')[4]) ?? 0;

      // Create the order document
      DocumentReference orderRef =
          await FirebaseFirestore.instance.collection('orders').add({
        'ref_no': refNo,
        'total_amount': totalPrice,
        'shipping_fee': 30.0,
        'user_id': userId,
        'payment_method': paymentMethods.firstWhere(
              (option) => option['value'] == selectedPaymentMethod,
              orElse: () => {'label': 'Unknown'},
            )['label'] ??
            'Cash on Delivery',
        'datetime_purchased': datetimePurchased,
        'order_status': 1, // Default to "For Delivery"
        'delivery_location': {
          'state_province': userAddress.split(', ')[3],
          'city_municipality': userAddress.split(', ')[2],
          'barangay': userAddress.split(', ')[1],
          'zip': zipCode,
          'house_no_building_street': userAddress.split(', ')[0],
        },
      });

      // Add products to the products_ordered sub-collection
      for (var item in cartItems) {
        await orderRef.collection('products_ordered').add({
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'price': item['price'],
          'name': item['name'],
          'image': item['image'],
        });
      }

      // Clear the cart
      await clearCart(userId);

      // Show success message
      print("Order placed successfully with ref_no: $refNo");
      setState(() {
        cartItems.clear();
        totalAmount = 0.0;
      });
      toastification.show(
        context: context,
        title: Text('Order placed successfully'),
        description: Text(
            'Your order with the reference no. $refNo has been placed successfully.'),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 4),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyOrdersPage(),
        ),
      );
    } catch (e) {
      print("Error placing order: $e");
      toastification.show(
        context: context,
        title: Text('Error placing order'),
        description: Text('Failed to place your order. Please try again.'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Checkout Page",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFE0B6),
        fontFamily: 'Inter',
      ),
      home: Scaffold(
        backgroundColor: Color(0xFFFFE0B6),
        appBar: AppBarWithMenuAndTitle(title: "Checkout"),
        drawer: UserDrawer(),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC345E)),
                  backgroundColor: Color(0xFFFF7171),
                  strokeWidth: 5.0,
                ),
              )
            : SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.topCenter,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Details
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          padding: EdgeInsets.all(16),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2),
                                child: Icon(
                                  Icons.location_on,
                                  size: 25,
                                  color: Color(0xFF462521),
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    fullName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF462521),
                                    ),
                                    softWrap: true,
                                  ),
                                  Text(
                                    userAddress,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF5C5B5B),
                                    ),
                                    softWrap: true,
                                  ),
                                  Text(
                                    userContactNo,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF5C5B5B),
                                    ),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Items Header
                        Container(
                          margin: EdgeInsets.only(left: 20, top: 15),
                          child: Text(
                            "Items",
                            style: TextStyle(
                              fontSize: 25,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF462521),
                            ),
                            softWrap: true,
                          ),
                        ),
                        // Items List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
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
                              child: Row(children: [
                                // Donut Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: item['image'] != null &&
                                            item['image'].isNotEmpty &&
                                            item['image']
                                                .startsWith('data:image/')
                                        ? Image.memory(
                                            base64Decode(
                                                item['image'].split(',').last),
                                            fit: BoxFit.contain,
                                          )
                                        : Image.asset(
                                            item['image'] != null &&
                                                    item['image'].isNotEmpty
                                                ? item['image']
                                                : 'assets/front_donut/fdonut1.png',
                                            fit: BoxFit.contain,
                                          ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                // Donut Name and Price
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'],
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF462521),
                                        ),
                                      ),
                                      Text(
                                        '₱${item['price'].toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF462521),
                                        ),
                                      ),
                                    ]),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.only(right: 10),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Qty: ",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            color: Color(0xFF462521),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${item['quantity']}',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            color: Color(0xFF462521),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                            );
                          },
                        ),
                        // Payment Method Section
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFF462521)),
                              SizedBox(height: 10),
                              Text(
                                "Payment Method",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF462521),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Note: We don't accept card payments yet.",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF462521),
                                ),
                              ),
                              SizedBox(height: 5),
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
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
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
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                      color: Color(0xFF462521),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Order Summary Section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFF462521)),
                              SizedBox(height: 10),
                              Text(
                                "Order Summary",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF462521),
                                ),
                              ),
                              SizedBox(height: 10),
                              // Order Subtotal
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Order Subtotal",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF462521),
                                    ),
                                  ),
                                  Text(
                                    "₱${totalAmount.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF462521),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              // Shipping
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Shipping",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF462521),
                                    ),
                                  ),
                                  Text(
                                    "₱30.00",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF462521),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              // Payment Method
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Payment Method",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF462521),
                                    ),
                                  ),
                                  Text(
                                    selectedPaymentMethod,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF462521),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              // Order Total
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Order Total",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF462521),
                                    ),
                                  ),
                                  Text(
                                    "₱${(totalAmount + 30).toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFE23F61),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              // Place Order Button
                              Center(
                                child: GradientButton(
                                  text: "Place Order",
                                  onPressed: () async {
                                    print(
                                        "Order placed with $selectedPaymentMethod");
                                    await placeOrder();
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
