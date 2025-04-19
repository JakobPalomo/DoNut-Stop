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
    {"label": "Credit Card", "value": 2},
  ];

  @override
  void initState() {
    super.initState();
    print("Order data: ${widget.order}");
  }

  Widget _buildOrderDetail(String label, String value) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF462521),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  double degreesToRadians(double degrees) {
    return degrees * (3.1415926535897932 / 180);
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
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                width: double.infinity,
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 800),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Order Details
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(20),
                          child: Column(children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: _buildOrderDetail("Reference No.",
                                          widget.order['ref_no'] ?? '-')),
                                  Expanded(
                                      child: _buildOrderDetail(
                                          "Date and Time of Order",
                                          widget.order['datetime_purchased'] ??
                                              '-')),
                                ]),
                            SizedBox(height: 20),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: _buildOrderDetail(
                                          "Payment Method",
                                          paymentMethods.firstWhere(
                                                (option) =>
                                                    option['value'] ==
                                                    (widget.order[
                                                            'payment_method'] ??
                                                        1),
                                                orElse: () =>
                                                    {'label': 'Unknown'},
                                              )['label'] ??
                                              'Cash on Delivery')),
                                  Expanded(
                                      child: _buildOrderDetail(
                                          "Order Status",
                                          orderStatuses.firstWhere(
                                                (option) =>
                                                    option['value'] ==
                                                    (widget.order[
                                                            'order_status'] ??
                                                        1),
                                                orElse: () =>
                                                    {'label': 'Unknown'},
                                              )['label'] ??
                                              'For Delivery')),
                                ]),
                            SizedBox(height: 20),
                            Row(children: [
                              Expanded(
                                child: _buildOrderDetail(
                                  "Delivery Location",
                                  "${widget.order['delivery_location']?['house_no_building_street'] ?? ''}, "
                                      "Brgy. ${widget.order['delivery_location']?['barangay'] ?? ''}, "
                                      "${widget.order['delivery_location']?['city_municipality'] ?? ''}, "
                                      "${widget.order['delivery_location']?['state_province'] ?? ''}, "
                                      "${widget.order['delivery_location']?['zip']?.toString() ?? ''}",
                                ),
                              ),
                              Expanded(
                                child: _buildOrderDetail(
                                  "Purchased By",
                                  "${widget.order['user_data']?['first_name'] ?? ''} ${widget.order['user_data']?['last_name'] ?? ''}",
                                ),
                              ),
                            ]),
                          ]),
                        ),
                        SizedBox(height: 20),
                        // Order Items
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Order Items",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF462521),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            ...widget.order['products_ordered']
                                .map<Widget>((item) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  //image_path
                                  Expanded(
                                      child: _buildOrderDetail(
                                          "Product Name", item['name'] ?? '-')),
                                  Expanded(
                                      child: _buildOrderDetail("Quantity",
                                          item['quantity']?.toString() ?? '-')),
                                  Expanded(
                                      child: _buildOrderDetail("Price",
                                          item['price']?.toString() ?? '-')),
                                ],
                              );
                            }).toList(),
                            Row(children: [
                              Expanded(
                                child: _buildOrderDetail(
                                    "Total Amount",
                                    widget.order['total_price']?.toString() ??
                                        '-'),
                              ),
                            ])
                          ]),
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
