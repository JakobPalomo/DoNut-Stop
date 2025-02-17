import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  final bool isFavInitial;

  ProductPage({
    this.isFavInitial = false,
  });

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late bool isFav;

  @override
  void initState() {
    super.initState();
    isFav = widget.isFavInitial;
  }

  @override
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
            // Donut Image Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/front_donut/fdonut3.png",
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Product Details Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Center(
                  // Ensure maxWidth applies correctly
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 800),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Favorite Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Strawberry Sprinkle",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF462521),
                                ),
                                softWrap: true,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                size: 30,
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: Color(0xFFCA2E55),
                              ),
                              onPressed: () {
                                setState(() {
                                  isFav = !isFav;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 30),

                        // About Donut Description
                        Text(
                          "About Donut",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Strawberry Sprinkles donut is a treat you can’t resist! With a soft, fluffy base coated in rich strawberry glaze and topped with colorful sprinkles, every bite is a perfect balance of sweetness.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        SizedBox(height: 20),

                        // Quantity Selector
                        SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 20,
                              runSpacing: 5,
                              children: [
                                Text(
                                  "Quantity",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                QuantitySelector(),
                              ],
                            )),
                        SizedBox(height: 20),

                        // Price & Add to Cart Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 30,
                            runSpacing: 30,
                            children: [
                              Text(
                                "₱50",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                width: double
                                    .infinity, // Take full width if wrapped
                                constraints: BoxConstraints(
                                    maxWidth: 200), // Limit max width
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFF7171),
                                      Color(0xFFDC345E)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 25),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Add to Cart",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuantitySelector extends StatefulWidget {
  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  int quantity = 1; // Initial quantity

  void increaseQuantity() {
    setState(() {
      quantity++; // Increase quantity
    });
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      // Prevent negative values
      setState(() {
        quantity--; // Decrease quantity
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove, color: Colors.black),
            onPressed: decreaseQuantity, // Decrease on click
          ),
          SizedBox(width: 10),
          Text(
            "$quantity", // Display current quantity
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: increaseQuantity, // Increase on click
          ),
        ],
      ),
    );
  }
}
