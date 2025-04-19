import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itelec_quiz_one/components/buttons.dart';
import 'package:itelec_quiz_one/components/data_table.dart';
import 'package:itelec_quiz_one/components/pagination.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/pages/admin/view_order.dart';
import 'package:toastification/toastification.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageOrdersPage extends StatefulWidget {
  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  final CollectionReference _ordersCollection =
      FirebaseFirestore.instance.collection('orders');
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final TextEditingController _searchController = TextEditingController();

  int selectedRole = 1; // Default to 1 (Customer)

  final List<Map<String, dynamic>> roles = [
    {'value': 1, 'label': 'Customer', 'drawer': UserDrawer()},
    {'value': 2, 'label': 'Employee', 'drawer': EmployeeDrawer()},
    {'value': 3, 'label': 'Admin', 'drawer': AdminDrawer()},
  ];

  final List<Map<String, dynamic>> paymentMethods = [
    {'value': 1, 'label': 'Cash on Delivery'},
    {'value': 2, 'label': 'GCash'},
  ];

  void _updateOrderStatus(String id, int newOrderStatus) async {
    // Fetch the current order status from Firestore
    final orderDoc = await _ordersCollection.doc(id).get();
    final currentOrderStatus =
        (orderDoc.data() as Map<String, dynamic>?)?['order_status'];

    // Check if the order status is already the same
    if (currentOrderStatus == newOrderStatus) {
      return;
    }

    // Proceed with the update if the order status has changed
    await _ordersCollection.doc(id).update({'order_status': newOrderStatus});

    // Show a success message
    toastification.show(
      context: context,
      title: Text('Order Status Updated'),
      description: Text('Order status has been updated successfully.'),
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 4),
    );
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

  // Filter data
  final List<Map<String, dynamic>> filters = [
    {
      "label": "All",
      "value": 0,
      "count": 0,
      "color": Color(0xFFCE895B),
      "activeColor": Color(0xFFF9DBB3),
    },
    {
      "label": "For Delivery",
      "value": 1,
      "count": 0,
      "color": Color(0xFFFFB957),
      "activeColor": Color(0xFFFFE7C7),
    },
    {
      "label": "Shipped",
      "value": 2,
      "count": 0,
      "color": Color(0xFFFF7859),
      "activeColor": Color(0xFFFFD7C5),
    },
    {
      "label": "Cancelled",
      "value": 3,
      "count": 0,
      "color": Color(0xFFFF8BA8),
      "activeColor": Color(0xFFFFD7E0),
    },
  ];
  // Table data
  final List<Map<String, dynamic>> dummyOrders = [
    {
      "datetime_purchased": "2024-01-10T10:30:00",
      "ref_no": "OR202504190753001",
      "order_status": 3,
    },
    {
      "datetime_purchased": "2024-03-05T14:20:00",
      "ref_no": "OR202504190753002",
      "order_status": 1,
    },
    {
      "datetime_purchased": "2023-12-22T09:15:00",
      "ref_no": "OR202504190753003",
      "order_status": 2,
    },
    {
      "datetime_purchased": "2024-02-28T17:45:00",
      "ref_no": "OR202504190753004",
      "order_status": 1,
    },
    {
      "datetime_purchased": "2024-01-01T12:00:00",
      "ref_no": "OR202504190753005",
      "order_status": 3,
    },
    {
      "datetime_purchased": "2024-03-15T08:30:00",
      "ref_no": "OR202504190753006",
      "order_status": 2,
    },
    {
      "datetime_purchased": "2023-11-10T11:10:00",
      "ref_no": "OR202504190753007",
      "order_status": 1,
    },
  ];
  final List<Map<String, dynamic>> columns = [
    {
      "label": "Date & Time",
      "column": "datetime_purchased",
      "sortable": true,
      "type": "date",
      "width": 110
    },
    {
      "label": "Reference No.",
      "column": "ref_no",
      "sortable": true,
      "type": "string",
      "width": 170
    },
    {
      "label": "Order Status",
      "column": "order_status",
      "sortable": true,
      "type": "string",
      "width": 150,
    },
    {
      "label": "Total Amount (₱)",
      "column": "total_amount",
      "sortable": true,
      "type": "number",
      "width": 150,
    },
    {
      "label": "Purchased By",
      "column": "purchased_by",
      "sortable": true,
      "type": "string",
      "width": 240,
    },
    {
      "label": "Payment Method",
      "column": "payment_method_string",
      "sortable": true,
      "type": "string",
      "width": 200,
    },
    {
      "label": "Delivery Location",
      "column": "delivery_location_address",
      "sortable": true,
      "type": "string",
      "width": 500,
    },
    {
      "label": "",
      "column": "actions",
      "sortable": false,
      "type": "actions",
      "width": 40,
    },
  ];
  final List<Map<String, Object>> dropdowns = [
    {
      "row": "order_status",
      "options": [
        {"label": "For Delivery", "value": 1},
        {"label": "Shipped", "value": 2},
        {"label": "Cancelled", "value": 3},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeSelectedRole();
  }

  Future<void> _initializeSelectedRole() async {
    try {
      // Get the authenticated user's UID
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("No authenticated user found.");
      }

      final userId = currentUser.uid;

      // Fetch the user's main document
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        throw Exception("User document not found.");
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      // Set the selectedRole based on the user's role
      setState(() {
        selectedRole = userData['role'] ?? 1; // Default to 1 (Customer)
      });

      print("User role initialized: $selectedRole");
    } catch (e) {
      print("Error initializing selectedRole: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch user role."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Manage Orders",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFFFE0B6),
        appBar: AppBarWithMenuAndTitle(title: "Manage Orders"),
        drawer: roles.firstWhere(
          (role) => role['value'] == selectedRole,
          orElse: () => {'drawer': EmployeeDrawer()},
        )['drawer'],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            Container(
              padding: EdgeInsets.fromLTRB(25, 20, 25, 16),
              child: SizedBox(
                height: 42,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    focusColor: Color(0xFF684440),
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: Colors.white,
                      selectionColor: Color(0xFF684440),
                      selectionHandleColor: Color(0xFF684440),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      setState(() {}); // Trigger a rebuild to pass the query
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      filled: true,
                      fillColor: Colors.brown.shade800,
                      hintStyle: TextStyle(color: Colors.white70),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Icon(Icons.search, color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    cursorColor: Colors.white,
                  ),
                ),
              ),
            ),

            // Main Content (StreamBuilder and Pagination)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 23),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _ordersCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFDC345E)),
                          backgroundColor: Color(0xFFFF7171),
                          strokeWidth: 5.0,
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      // Update filter counts to 0 if no orders are found
                      for (var filter in filters) {
                        filter['count'] = 0;
                      }
                      return const Center(
                          child: Text(
                        'No orders found.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC7A889),
                        ),
                      ));
                    }

                    print(
                        "Fetched order data: ${snapshot.data!.docs.map((doc) => doc.data())}");

                    // Fetch orders and their subcollections
                    final ordersFuture =
                        Future.wait(snapshot.data!.docs.map((doc) async {
                      final data = doc.data() as Map<String, dynamic>;

                      // Fetch the products_ordered subcollection
                      final productsOrderedSnapshot = await doc.reference
                          .collection('products_ordered')
                          .get();
                      final productsOrdered = productsOrderedSnapshot.docs
                          .map((productsOrderedDoc) {
                        return {
                          ...productsOrderedDoc.data(),
                          "id": productsOrderedDoc.id,
                        };
                      }).toList();

                      final userData = await _findUserById(data['user_id']);
                      final deliveryLocation = data['delivery_location'];
                      final formattedAddress = deliveryLocation.isNotEmpty
                          ? "${deliveryLocation['house_no_building_street'] ?? ''}, "
                              "Brgy. ${deliveryLocation['barangay'] ?? ''}, "
                              "${deliveryLocation['city_municipality'] ?? ''}, "
                              "${deliveryLocation['state_province'] ?? ''}, "
                              "${deliveryLocation['zip']?.toString() ?? ''}"
                          : 'No address available';
                      final paymentMethodString = paymentMethods.firstWhere(
                        (method) => method['value'] == data['payment_method'],
                        orElse: () => {'label': 'Unknown'},
                      )['label'];

                      // Combine orders data with products_ordered
                      return {
                        ...data,
                        "id": doc.id,
                        "products_ordered": productsOrdered,
                        "datetime_purchased":
                            data['datetime_purchased'] is Timestamp
                                ? DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(
                                    data['datetime_purchased']
                                        .toDate()) // Correct field
                                : "2024-01-10T10:30:00",
                        "user_data": userData,
                        "purchased_by":
                            "${userData['first_name']} ${userData['last_name']}",
                        "payment_method_string": paymentMethodString,
                        "delivery_location_address": formattedAddress,
                      };
                    }).toList());

                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: ordersFuture,
                      builder: (context, ordersSnapshot) {
                        if (ordersSnapshot.connectionState ==
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

                        if (!ordersSnapshot.hasData ||
                            ordersSnapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No orders found.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFC7A889),
                                  )));
                        }

                        final orders = ordersSnapshot.data!;

                        // Dynamically update filter counts
                        for (var filter in filters) {
                          if (filter['value'] == 0) {
                            // "All" filter
                            filter['count'] = orders.length;
                          } else {
                            // Order status-specific filters
                            filter['count'] = orders
                                .where((order) =>
                                    order['order_status'] == filter['value'])
                                .length;
                          }
                        }

                        return CustomDataTable(
                          data: orders,
                          columns: columns,
                          filters: filters,
                          rowsPerPage: 10,
                          searchQuery: _searchController.text,
                          dropdowns: dropdowns,
                          onRoleChanged: (row, newRole) {
                            _updateOrderStatus(row['id'], newRole);
                          },
                          actionsBuilder: (row) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility,
                                      color: Color(0xFFCA2E55)),
                                  onPressed: () {
                                    // Handle view action
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ViewOrderPage(order: row)),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
