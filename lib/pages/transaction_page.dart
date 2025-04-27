import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/components/buttons.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:itelec_quiz_one/pages/catalog_page.dart';

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
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFE0B6),
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF462521)),
          title: const Text(
            "Transaction",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF462521),
            ),
          ),
        ),
        drawer: UserDrawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFFE23F61),
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                "Transaction Completed",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Color(0xFF462521),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Your donut is ready for delivery!",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF665A49),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF462521),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Account Name: $accountName",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFF665A49),
                      ),
                    ),
                    Text(
                      "Amount Paid: ₱${amountPaid.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFF665A49),
                      ),
                    ),
                    Text(
                      "Orders: $orders",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFF665A49),
                      ),
                    ),
                    Text(
                      "Ref. No.: $refNo",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFFE23F61),
                      ),
                    ),
                    Text(
                      dateTime,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFF665A49),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              GradientButton(
                text: "Back to Home",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CatalogPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}