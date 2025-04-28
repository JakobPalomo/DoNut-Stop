import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:flutter/services.dart';
import 'package:itelec_quiz_one/components/buttons.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/pages/registration_page.dart';
import 'package:toastification/toastification.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert'; // For Base64 encoding
import 'package:dropdown_button2/dropdown_button2.dart';

class ViewOrderPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const ViewOrderPage({this.order = const {}, super.key});

  @override
  State<ViewOrderPage> createState() => _ViewOrderPageState();
}

class _ViewOrderPageState extends State<ViewOrderPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> orderStatuses = [
    {"label": "For Delivery", "value": 1},
    {"label": "Shipped", "value": 2},
    {"label": "Cancelled", "value": 3},
  ];

  final List<Map<String, dynamic>> paymentMethods = [
    {"label": "Cash on Delivery", "value": 1},
    {"label": "GCash", "value": 2},
    {"label": "Credit Card", "value": 3},
  ];

  @override
  void initState() {
    super.initState();
    print("Order data: ${widget.order}");
  }

  Widget _buildOrderDetail(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFD8CFC9),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF462521),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  double degreesToRadians(double degrees) {
    return degrees * (3.1415926535897932 / 180);
  }

  double _calculateSubtotal(List<Map<String, dynamic>> productsOrdered) {
    double total = 0.0;

    for (var product in productsOrdered) {
      final price = product['price'] ?? 0.0; // Default to 0.0 if price is null
      final quantity =
          product['quantity'] ?? 0; // Default to 0 if quantity is null
      total += price * quantity;
    }

    return total;
  }

  Widget _buildDropdown({
    required String label,
    required int value,
    required List<Map<String, dynamic>> options,
    required Function(int?) onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Color(0xFFEC2023)),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 10),
        DropdownButton2<int>(
          value: value,
          isExpanded: false,
          items: options.map((option) {
            return DropdownMenuItem<int>(
              value: option['value'] as int,
              child: Text(option['label'] as String),
            );
          }).toList(),
          onChanged: onChanged,
          underline: const SizedBox(),
          buttonStyleData: ButtonStyleData(
            height: 47,
            width: 240,
            padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Color(0xFF303030)),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            width: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(0),
          ),
          menuItemStyleData: MenuItemStyleData(
            height: 40,
            padding: const EdgeInsets.only(left: 10),
          ),
          iconStyleData: IconStyleData(
            icon: Transform.rotate(
              angle: degreesToRadians(90),
              child: const Icon(Icons.chevron_right),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "View Order",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFE0B6),
        fontFamily: 'Inter',
      ),
      home: Scaffold(
        backgroundColor: Color(0xFFFFE0B6),
        appBar: AppBarWithBackAndTitle(
          title: "View Order",
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: CustomScrollView(
          slivers: [
            // Order Details Section
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 800),
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order Details",
                        style: TextStyle(
                          fontSize: 25,
                          color: Color(0xFF462521),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(20),
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
                        child: Column(
                          children: [
                            _buildOrderDetail(
                              "Reference No.",
                              widget.order['ref_no'] ?? '-',
                            ),
                            _buildOrderDetail(
                              "Date and Time of Order",
                              widget.order['datetime_purchased'] ?? '-',
                            ),
                            _buildOrderDetail(
                              "Payment Method",
                              paymentMethods.firstWhere(
                                    (option) =>
                                        option['value'] ==
                                        (widget.order['payment_method'] ?? 1),
                                    orElse: () => {'label': 'Unknown'},
                                  )['label'] ??
                                  'Cash on Delivery',
                            ),
                            _buildOrderDetail(
                              "Order Status",
                              orderStatuses.firstWhere(
                                    (option) =>
                                        option['value'] ==
                                        (widget.order['order_status'] ?? 1),
                                    orElse: () => {'label': 'Unknown'},
                                  )['label'] ??
                                  'For Delivery',
                            ),
                            _buildOrderDetail(
                              "Delivery Location",
                              "${widget.order['delivery_location']?['house_no_building_street'] ?? ''}, "
                                  "Brgy. ${widget.order['delivery_location']?['barangay'] ?? ''}, "
                                  "${widget.order['delivery_location']?['city_municipality'] ?? ''}, "
                                  "${widget.order['delivery_location']?['state_province'] ?? ''}, "
                                  "${widget.order['delivery_location']?['zip']?.toString() ?? ''}",
                            ),
                            _buildOrderDetail(
                              "Purchased By",
                              "${widget.order['user_data']?['first_name'] ?? ''} ${widget.order['user_data']?['last_name'] ?? ''}",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Order Items Section
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 800),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order Items",
                        style: TextStyle(
                          fontSize: 25,
                          color: Color(0xFF462521),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...widget.order['products_ordered'].map<Widget>((item) {
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
                          padding: const EdgeInsets.fromLTRB(5, 5, 25, 5),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Leading Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: item['image'] != null &&
                                          item['image']
                                              .toString()
                                              .startsWith('data:image/')
                                      ? Image.memory(
                                          base64Decode(item['image']
                                              .toString()
                                              .split(',')
                                              .last),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          item['image'] ??
                                              'assets/front_donut/fdonut1.png',
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
                                      item['name'] ?? 'Unnamed Product',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF462521),
                                      ),
                                    ),
                                    Text(
                                      '₱${item['price']?.toStringAsFixed(2) ?? '0.00'}',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF462521),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                'x ${item['quantity']?.toString() ?? '-'}',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF462521),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(right: 5),
                              alignment: Alignment.centerRight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex:
                                            2, // Label side takes 2 parts of the space
                                        child: Text(
                                          "Subtotal:",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF462521),
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex:
                                            1, // Amount side takes 1 part of the space
                                        child: Text(
                                          '₱${_calculateSubtotal(widget.order['products_ordered'])?.toStringAsFixed(2) ?? '0.00'}',
                                          textAlign: TextAlign
                                              .right, // Align the amount to the right
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF462521),
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex:
                                            2, // Label side takes 2 parts of the space
                                        child: Text(
                                          "Shipping Fee:",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF462521),
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex:
                                            1, // Amount side takes 1 part of the space
                                        child: Text(
                                          '₱${widget.order['shipping_fee']?.toStringAsFixed(2) ?? '30.00'}',
                                          textAlign: TextAlign
                                              .right, // Align the amount to the right
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF462521),
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 1,
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF462521),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex:
                                            2, // Label side takes 2 parts of the space
                                        child: Text(
                                          "Total Amount:",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF462521),
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex:
                                            1, // Amount side takes 1 part of the space
                                        child: Text(
                                          '₱${widget.order['total_amount']?.toStringAsFixed(2) ?? '0.00'}',
                                          textAlign: TextAlign
                                              .right, // Align the amount to the right
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFFE23F61),
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
