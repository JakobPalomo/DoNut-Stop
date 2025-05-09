import 'package:flutter/material.dart';
import 'package:donut_stop/components/buttons.dart';
import 'package:donut_stop/components/user_drawers.dart';
import 'package:donut_stop/pages/catalog_page.dart';
import 'package:intl/intl.dart';
import 'package:donut_stop/pages/my_orders_page.dart';

class TransactionPage extends StatelessWidget {
  final String accountName;
  final double amountPaid;
  final String orders;
  final String refNo;
  final String dateTime;

  const TransactionPage({
    Key? key,
    required this.accountName,
    required this.amountPaid,
    required this.orders,
    required this.refNo,
    required this.dateTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Transaction Page",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFE0B6),
      ),
      home: Scaffold(
        appBar: AppBarWithMenuAndTitle(
          title: "Transaction",
        ),
        backgroundColor: Color(0xFFFFE0B6),
        drawer: UserDrawer(),
        body: CustomScrollView(
          slivers: [
            // SliverList for the main content
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 100, 16, 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFFE23F61),
                                size: 100,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Transaction Completed",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 35,
                                  color: Color(0xFF462521),
                                ),
                              ),
                              const Text(
                                "Your donut is ready for delivery!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF462521),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          constraints: BoxConstraints(maxWidth: 800),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Transaction Receipt",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: Color(0xFF462521),
                                ),
                              ),
                              const SizedBox(height: 15),
                              // Key-Value Pairs with Expanded
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "Account Name:",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Color(0xFF462521),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      accountName,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Color(0xFF5C5B5B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "Amount Paid:",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Color(0xFF462521),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "₱${amountPaid.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Color(0xFF5C5B5B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "Orders:",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Color(0xFF462521),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      orders,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Color(0xFF5C5B5B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "Reference No.:",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Color(0xFF462521),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      refNo,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Color(0xFFE23F61),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "Date & Time:",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Color(0xFF462521),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      dateTime,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Color(0xFF5C5B5B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          constraints: BoxConstraints(maxWidth: 800),
                          child: SizedBox(
                            width: double.infinity,
                            child: GradientButton(
                              text: "Check My Orders",
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyOrdersPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
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
