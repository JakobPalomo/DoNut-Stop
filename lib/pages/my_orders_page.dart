import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:itelec_quiz_one/pages/admin/view_order.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({Key? key}) : super(key: key);

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference _ordersCollection =
      FirebaseFirestore.instance.collection('orders');
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  bool isLoading = true;
  String userId = '';
  List<Map<String, dynamic>> userOrders = [];

  final List<Map<String, dynamic>> orderStatuses = [
    {
      "label": "For Delivery",
      "value": 1,
      "color": Color.fromARGB(255, 253, 191, 105)
    },
    {
      "label": "Shipped",
      "value": 2,
      "color": Color.fromARGB(255, 255, 145, 121)
    },
    {
      "label": "Cancelled",
      "value": 3,
      "color": Color.fromARGB(255, 252, 146, 173)
    },
  ];

  final List<Map<String, dynamic>> paymentMethods = [
    {'value': 1, 'label': 'Cash on Delivery'},
    {'value': 2, 'label': 'GCash'},
  ];

  // Dummy data for orders
  final List<Map<String, dynamic>> orders = [
    {
      'ref_no': '12345678',
      'order_staus': 1,
      'total_amount': 200.00,
      'products_ordered': [
        {
          'name': 'Strawberry Wheel',
          'price': 50.00,
          'quantity': 1,
          'image': 'assets/front_donut/fdonut1.png'
        },
        {
          'name': 'Chocolate Glaze',
          'price': 50.00,
          'quantity': 1,
          'image': 'assets/front_donut/fdonut2.png'
        }
      ]
    },
    {
      'ref_no': '12345678',
      'order_staus': 2,
      'total_amount': 200.00,
      'products_ordered': [
        {
          'name': 'The Crocy',
          'price': 50.00,
          'quantity': 1,
          'image': 'assets/front_donut/fdonut3.png'
        }
      ]
    },
    {
      'ref_no': '12345678',
      'order_staus': 3,
      'total_amount': 200.00,
      'products_ordered': [
        {
          'name': 'Choc-O-Late',
          'price': 50.00,
          'quantity': 1,
          'image': 'assets/front_donut/fdonut4.png'
        },
        {
          'name': 'Glizzy Glaze',
          'price': 50.00,
          'quantity': 1,
          'image': 'assets/front_donut/fdonut5.png'
        },
        {
          'name': 'Berry Blue',
          'price': 50.00,
          'quantity': 1,
          'image': 'assets/front_donut/fdonut6.png'
        }
      ]
    },
    {
      'ref_no': '12345678',
      'order_staus': 2,
      'total_amount': 200.00,
      'products_ordered': [
        {
          'name': 'Ashley Marilag',
          'price': 50.00,
          'quantity': 1,
          'image': 'assets/front_donut/fdonut7.png'
        },
        {
          'name': 'Chocolate Glaze',
          'price': 50.00,
          'quantity': 1,
          'image': 'assets/front_donut/fdonut8.png'
        }
      ]
    }
  ];

  Future<void> _initializeUserOrdersData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Get the authenticated user's UID
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        throw Exception("No authenticated user found.");
      }

      final uid = currentUser.uid;
      print("Authenticated user ID: $uid");
      setState(() {
        userId = uid;
      });
      await fetchUserOrders(uid, _ordersCollection);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error initializing user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch user orders."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _findUserById(String id) async {
    // Fetch the user document by ID
    final userDoc = await _usersCollection.doc(id).get();
    var userData = <String, dynamic>{};
    if (userDoc.exists) {
      // User found, do something with the data
      userData = userDoc.data() as Map<String, dynamic>;
      print("User data: $userData");
    } else {
      // User not found
      print("User not found");
    }
    return userData;
  }

  Future<void> fetchUserOrders(
      String uid, CollectionReference ordersCollection) async {
    try {
      // Query the orders collection for the current user's orders
      final QuerySnapshot querySnapshot = await ordersCollection
          .where('user_id', isEqualTo: uid)
          .orderBy('datetime_purchased', descending: true)
          .get();

      // Clear the existing userOrders list
      userOrders.clear();

      // Iterate through the orders and fetch the products_ordered sub-collection
      for (var doc in querySnapshot.docs) {
        final orderData = doc.data() as Map<String, dynamic>;

        // Fetch the products_ordered sub-collection
        final QuerySnapshot productsSnapshot =
            await doc.reference.collection('products_ordered').get();

        // Map the products_ordered data
        final List<Map<String, dynamic>> productsOrdered = productsSnapshot.docs
            .map((productDoc) => productDoc.data() as Map<String, dynamic>)
            .toList();

        // Fetch user data for the order
        final userData = await _findUserById(uid);

        // Format the delivery location
        final deliveryLocation = orderData['delivery_location'];
        final formattedAddress = deliveryLocation.isNotEmpty
            ? "${deliveryLocation['house_no_building_street'] ?? ''}, "
                "Brgy. ${deliveryLocation['barangay'] ?? ''}, "
                "${deliveryLocation['city_municipality'] ?? ''}, "
                "${deliveryLocation['state_province'] ?? ''}, "
                "${deliveryLocation['zip']?.toString() ?? ''}"
            : 'No address available';

        // Map the payment method
        final paymentMethodString = paymentMethods.firstWhere(
          (method) => method['value'] == orderData['payment_method'],
          orElse: () => {'label': 'Unknown'},
        )['label'];

        // Add the order data to the userOrders list
        userOrders.add({
          'id': doc.id,
          'user_id': orderData['user_id'],
          'ref_no': orderData['ref_no'],
          'order_status': orderData['order_status'],
          'total_amount': orderData['total_amount'],
          'shipping_fee': orderData['shipping_fee'],
          "datetime_purchased": orderData['datetime_purchased'] is Timestamp
              ? DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                  .format(orderData['datetime_purchased'].toDate())
              : "2024-01-10T10:30:00",
          "user_data": userData,
          "purchased_by": "${userData['first_name']} ${userData['last_name']}",
          'delivery_location': orderData['delivery_location'],
          "delivery_location_address": formattedAddress,
          'payment_method': orderData['payment_method'],
          "payment_method_string": paymentMethodString,
          'products_ordered': productsOrdered,
        });
      }

      print("Fetched ${userOrders.length} orders for user ID: $uid");
      // print("User orders: $userOrders");
    } catch (e) {
      print("Error fetching user orders: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch user orders."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeUserOrdersData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithMenuAndTitle(title: "My Orders"),
      drawer: UserDrawer(),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC345E)),
                backgroundColor: Color(0xFFFF7171),
                strokeWidth: 5.0,
              ),
            )
          : Container(
              color: Color(0xFFFFE1B7),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 5),
                      child: Text(
                        "Order History",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF462521),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: userOrders.length,
                      itemBuilder: (context, orderIndex) {
                        final order = userOrders[orderIndex];
                        return Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical:
                                  8), // hover/ripple is only visible in the margin
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
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // Handle view action
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ViewOrderPage(order: order),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              splashColor: Colors.brown
                                  .withOpacity(0.2), // Ripple effect color
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 20, 20, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: 'Ref. No. ',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF462521),
                                            ),
                                            children: [
                                              TextSpan(
                                                text: order['ref_no'],
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w900,
                                                  color: Color(0xFFCA2E55),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: orderStatuses.firstWhere(
                                              (status) =>
                                                  status['value'] ==
                                                  order['order_status'],
                                              orElse: () => {
                                                "label": "Unknown",
                                                "value": -1,
                                                "color": Colors.grey[400],
                                              },
                                            )['color'],
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            orderStatuses.firstWhere(
                                              (status) =>
                                                  status['value'] ==
                                                  order['order_status'],
                                              orElse: () => {
                                                "label": "Unknown",
                                                "value": -1,
                                                "color": Colors.grey[400],
                                              },
                                            )['label'],
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount:
                                            order["products_ordered"].length,
                                        itemBuilder: (context, itemIndex) {
                                          final item = order["products_ordered"]
                                              [itemIndex];
                                          // Add a divider between items, but not after the last item
                                          bool showDivider = itemIndex <
                                              order["products_ordered"].length -
                                                  1;

                                          return Column(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8),
                                                child: Row(children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    child: SizedBox(
                                                      width: 80,
                                                      height: 80,
                                                      child: item['image'] !=
                                                                  null &&
                                                              item['image']
                                                                  .isNotEmpty &&
                                                              item['image']
                                                                  .startsWith(
                                                                      'data:image/')
                                                          ? Image.memory(
                                                              base64Decode(
                                                                  item['image']
                                                                      .split(
                                                                          ',')
                                                                      .last),
                                                              fit: BoxFit
                                                                  .contain,
                                                            )
                                                          : Image.asset(
                                                              item['image'] !=
                                                                          null &&
                                                                      item['image']
                                                                          .isNotEmpty
                                                                  ? item[
                                                                      'image']
                                                                  : 'assets/front_donut/fdonut1.png',
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          item['name'],
                                                          style: TextStyle(
                                                            fontFamily: 'Inter',
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Color(
                                                                0xFF462521),
                                                          ),
                                                        ),
                                                        Text(
                                                          '₱${item['price'].toStringAsFixed(2)}',
                                                          style: TextStyle(
                                                            fontFamily: 'Inter',
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: Color(
                                                                0xFF462521),
                                                          ),
                                                        ),
                                                      ]),
                                                  Spacer(),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: "Qty: ",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF462521),
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                '${item['quantity']}',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF462521),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                              if (showDivider)
                                                Divider(
                                                    height: 1,
                                                    thickness: 1,
                                                    indent: 16,
                                                    endIndent: 16,
                                                    color: Color.fromARGB(
                                                        255, 187, 167, 154)),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 0, 20, 20),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'Total:  ',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF462521),
                                              ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '₱${order['total_amount']?.toStringAsFixed(2) ?? '0.00'}',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w900,
                                                    color: Color(0xFF462521),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ]),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ), // Bottom padding
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
