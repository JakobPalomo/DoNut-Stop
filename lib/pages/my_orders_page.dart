import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({Key? key}) : super(key: key);

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  // Dummy data for orders
  final List<Map<String, dynamic>> orders = [
    {
      'referenceNumber': '12345678',
      'items': [
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
      'referenceNumber': '12345678',
      'items': [
        {
          'name': 'The Crocy',
          'price': 50.00,
          'quantity': 1,
          'image': 'assets/front_donut/fdonut3.png'
        }
      ]
    },
    {
      'referenceNumber': '12345678',
      'items': [
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
      'referenceNumber': '12345678',
      'items': [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithMenuAndTitle(title: "My Orders"),
      drawer: UserDrawer(),
      body: Container(
        color: Color(0xFFFFE1B7),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Order History",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF462521),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, orderIndex) {
                  final order = orders[orderIndex];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(
                          0xFFFFEEE1), // Updated background color to FFEEE1
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: order['items'].length,
                              itemBuilder: (context, itemIndex) {
                                final item = order['items'][itemIndex];
                                // Add a divider between items, but not after the last item
                                bool showDivider =
                                    itemIndex < order['items'].length - 1;

                                return Column(
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.all(16),
                                      leading: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: AssetImage(item['image']),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        item['name'],
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF462521),
                                        ),
                                      ),
                                      subtitle: Text(
                                        "Quantity",
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          color: Color(0xFF462521),
                                        ),
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '₱${item['price'].toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF462521),
                                            ),
                                          ),
                                          Text(
                                            '${item['quantity']}x',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 14,
                                              color: Color(0xFF462521),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (showDivider)
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        indent: 16,
                                        endIndent: 16,
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        Positioned(
                          top: 8,
                          right: 16,
                          child: RichText(
                            text: TextSpan(
                              text: 'Ref. No. ',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey, // Gray color for 'Ref. No.'
                              ),
                              children: [
                                TextSpan(
                                  text: order['referenceNumber'],
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(
                                        0xFFEC2073), // Pink color for the reference number
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 16), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
