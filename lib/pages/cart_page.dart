import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int itemCount = 1;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Product Page Module",
      debugShowCheckedModeBanner: false, // Remove debug ribbon
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFE0B6),
        fontFamily: 'Inter', // Apply Inter font
      ),
      home: Scaffold(
        backgroundColor: Color(0xFFFFE0B6), // Background color
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Container(
            margin: EdgeInsets.only(left: 10, top: 10),
            child: IconButton(
              icon: Image.asset(
                'assets/icons/back.png',
                width: 20,
                height: 20,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20, top: 20),
              child: Expanded(
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
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
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
                  Image.asset(
                    'assets/front_donut/fdonut3.png',
                    width: 80,
                    height: 80,
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    "Strawberry Sprinkle",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF462521),
                    ),
                  ),
                  Text(
                    "₱50.00",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF462521),
                    ),
                  ),
                  ]),
                SizedBox(width: 20),
              Row(
                    children: [
                      Container (
                        decoration: BoxDecoration(
                         border: Border.all(
                          color: Color(0xFFFF7171), 
                          width: 1,
                    ),
                      borderRadius: BorderRadius.circular(10),
                      ),
                      child: SizedBox(
                        width: 30,
                        child: IconButton(
                          icon: Icon(Icons.remove, color:Color(0xFFFF7171), size: 12),
                          onPressed: () {
                            setState(() {
                              if (itemCount > 1) itemCount--; 
                            });
                          },
                        ),
                      ),
                    ),
                     SizedBox(width: 10),
                      Text(
                        "$itemCount", 
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
                        colors: [Color(0xFFFF7171), Color(0xFFDC345E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      width: 30,
                        child:IconButton(
                          icon: Icon(Icons.add, color: Color(0xFF462521),size: 12),
                          onPressed: () {
                            setState(() {
                              itemCount++;
                            });
                          },
                        ),
                      ),
                    ),
                    ],
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
