import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/pages/catalog_page.dart';

class ProductPage extends StatefulWidget {
  final String productId; // Add productId parameter
  final String image;
  final String title;
  final String description;
  final String oldPrice;
  final String newPrice;
  final bool isFavInitial;

  const ProductPage({
    required this.productId, // Make productId required
    this.image = "assets/front_donut/fdonut5.png",
    this.title = "Strawberry Sprimkle",
    this.description =
    "Strawberry Sprinkles doni is a treat you can't resist! With a soft, fluffy base coated in rich strawberry glaze and topped with colorful ssprinkle, every bite is a perfect  balance of sweetness.",
    this.oldPrice = "₱90",
    this.newPrice = "₱76",
    this.isFavInitial = false,
    super.key,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  late bool isFav;

  @override
  void initState() {
    super.initState();
    isFav = widget.isFavInitial;
  }

  Future<void> addToCart(String userId, String productId, int quantity) async {
    try {
      // Reference to the user's cart subcollection
      CollectionReference cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart');

      // Check if the product already exists in the cart
      QuerySnapshot existingProduct = await cartRef
          .where('product_id', isEqualTo: productId)
          .get();

      if (existingProduct.docs.isNotEmpty) {
        // If the product already exists, update the quantity
        DocumentReference productDoc = existingProduct.docs.first.reference;
        int currentQuantity = existingProduct.docs.first['quantity'];
        await productDoc.update({'quantity': currentQuantity + quantity});
        print("Product quantity updated in the cart.");
      } else {
        // If the product does not exist, add it to the cart
        await cartRef.add({
          'product_id': productId,
          'quantity': quantity,
        });
        print("Product added to the cart.");
      }
    } catch (e) {
      print("Error adding product to cart: $e");
    }
  }

  Future<void> toggleFavoriteStatus(String userId, String productId) async {
    try {
      DocumentReference userRef =
      FirebaseFirestore.instance.collection('users').doc(userId);

      DocumentSnapshot userSnapshot = await userRef.get();
      List<dynamic> favorites = userSnapshot['favorites'] ?? [];

      if (favorites.contains(productId)) {
        // Remove from favorites
        favorites.remove(productId);
        await userRef.update({'favorites': favorites});
        print("Product removed from favorites.");
      } else {
        // Add to favorites
        favorites.add(productId);
        await userRef.update({'favorites': favorites});
        print("Product added to favorites.");
      }
    } catch (e) {
      print("Error toggling favorite status: $e");
    }
  }

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
        appBar: AppBarWithBackAndTitle(),
        body: Column(
          children: [
            // Donut Image Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  widget.image,
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
                                widget.title,
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
                              onPressed: () async {
                                setState(() {
                                  isFav = !isFav;
                                });
                                String userId =
                                    "O5XpBhLgOGTHaLn5Oub9hRrwEhq1"; // Replace with dynamic userId
                                await toggleFavoriteStatus(userId, widget.productId);
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
                          widget.description,
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
                                widget.newPrice,
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
                                  onPressed: () async {
                                    String userId =
                                        "O5XpBhLgOGTHaLn5Oub9hRrwEhq1"; // Replace with dynamic userId
                                    int quantity =
                                    1; // Replace with the desired quantity or use the QuantitySelector value

                                    await addToCart(userId, widget.productId, quantity);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    padding:
                                    EdgeInsets.symmetric(vertical: 25),
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

class AppBarWithBackAndTitle extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFEDC690), // Updated background color
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CatalogPage()),
          );
        },
      ),
      title: Text(
        'Product Page',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
