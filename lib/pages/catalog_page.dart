import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/pages/product_page.dart';
import 'package:itelec_quiz_one/pages/cart_page.dart';
import 'package:itelec_quiz_one/pages/product_management_page.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:itelec_quiz_one/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';
import 'package:itelec_quiz_one/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
    });
  }

  void _checkUserSession(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      toastification.show(
        context: context,
        title: Text('Access Denied'),
        description: Text('You are not logged in yet.'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 4),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkUserSession(context); // Check session on page load
    return MaterialApp(
      title: "Catalog Page Module",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFE0B6),
      ),
      home: Scaffold(
        appBar: AppBarWithSearchAndCart(),
        drawer: UserDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(35, 35, 35, 25),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text(
                        "Welcome back, ${username ?? 'User'}!",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF462521),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Order your favourite donuts from here!",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF665A49),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const CatalogPageTodaysOffers(),
              const CatalogPageDonuts(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class ToggleChipsRow extends StatefulWidget {
  @override
  _ToggleChipsRowState createState() => _ToggleChipsRowState();
}

class _ToggleChipsRowState extends State<ToggleChipsRow> {
  String selectedChip = "Strawberry"; // Default selected chip

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: Row(
          children: [
            SizedBox(width: 35),
            _buildChip("Strawberry"),
            SizedBox(width: 8),
            _buildChip("Chocolate"),
            SizedBox(width: 8),
            _buildChip("Matcha"),
            SizedBox(width: 8),
            _buildChip("Cotton Candy"),
            SizedBox(width: 8),
            _buildChip("Glazed"),
            SizedBox(width: 8),
            _buildChip("Ube"),
            SizedBox(width: 35),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    bool isSelected = selectedChip == label;

    return MouseRegion(
      cursor: SystemMouseCursors.click, // Shows cursor effect
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedChip = label;
            });
            debugPrint("Selected Today's Offers: $label");
          },
          borderRadius: BorderRadius.circular(20), // Circle ripple
          splashColor: Colors.white.withOpacity(0.3), // White ripple effect
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFCA2E55) : Color(0xFFFFEEE1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                    fontFamily: 'Inter',
                    color: isSelected ? Colors.white : Color(0xFF665A49),
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OfferSelectionWidget extends StatefulWidget {
  final String image, title, description, newPrice;
  final bool isFavInitial;

  OfferSelectionWidget({
    required this.image,
    required this.title,
    required this.description,
    required this.newPrice,
    this.isFavInitial = false,
  });

  @override
  _OfferSelectionWidgetState createState() => _OfferSelectionWidgetState();
}

class _OfferSelectionWidgetState extends State<OfferSelectionWidget> {
  late bool isFav;

  @override
  void initState() {
    super.initState();
    isFav = widget.isFavInitial;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      child: MouseRegion(
        cursor: SystemMouseCursors.click, // Shows pointer cursor on hover
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              print("Navigating to ProductPage with:");
              print("Image: ${widget.image}");
              print("Title: ${widget.title}");
              print("Description: ${widget.description}");
              print("New Price: ${widget.newPrice}");

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductPage(
                        image: widget.image,
                        title: widget.title,
                        description: widget.description,
                        newPrice: widget.newPrice)),
              );
            },
            borderRadius:
                BorderRadius.circular(16), // Ensures ripple follows shape
            splashColor: Colors.brown.withOpacity(0.2), // Ripple effect color
            child: Ink(
              decoration: BoxDecoration(
                color: Color(0xFFFFEEE1), // Background color inside Ink
                borderRadius: BorderRadius.circular(16),
              ),
              width: 230,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 40, 10, 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            widget.image,
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 0,
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: Color(0xFFCA2E55),
                          ),
                          onPressed: () {
                            setState(() {
                              isFav = !isFav;
                            });
                          },
                          padding: EdgeInsets.all(5),
                          constraints: BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF462521),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xFF665A49),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(width: 10),
                            Text(
                              widget.newPrice,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                                color: Colors.black,
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
          ),
        ),
      ),
    );
  }
}

class DonutSelectionWidget extends StatelessWidget {
  final String image, title, newPrice;

  DonutSelectionWidget({
    required this.image,
    required this.title,
    required this.newPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      width: 200, // Adjusted width for better donut display
      child: Stack(
        clipBehavior: Clip.none, // Allows image to extend outside the container
        children: [
          // Donut Info Container (with ripple effect)
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: Material(
              color: Colors.transparent, // Prevents ripple from being hidden
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductPage(
                            image: image, title: title, newPrice: newPrice)),
                  );
                },
                borderRadius:
                    BorderRadius.circular(16), // Ensures ripple follows shape
                splashColor:
                    Colors.brown.withOpacity(0.2), // Ripple effect color
                child: Ink(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFEEE1), // Background color inside Ink
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: 200,
                    margin: EdgeInsets.only(
                        top: 40), // Ensures image extends outside
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SizedBox(height: 30), // Space for donut image
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF462521),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          newPrice,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            color: Color(0xFF000000),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Donut Image (Clickable but no ripple effect)
          Positioned(
            top: -15, // Moves the image slightly upwards
            left: 20,
            right: 20,
            child: MouseRegion(
              cursor: SystemMouseCursors.click, // Shows pointer cursor
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductPage(
                            image: image, title: title, newPrice: newPrice)),
                  );
                },
                child: Image.asset(
                  image,
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CatalogPageTodaysOffers extends StatefulWidget {
  const CatalogPageTodaysOffers({super.key});

  @override
  _CatalogPageTodaysOffersState createState() => _CatalogPageTodaysOffersState();
}

class _CatalogPageTodaysOffersState extends State<CatalogPageTodaysOffers> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(35, 0, 35, 0),
            child: Container(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 20,
                runSpacing: 5,
                children: [
                  Text(
                    "Today's Offers",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        debugPrint("See More clicked");
                      },
                      borderRadius: BorderRadius.circular(20),
                      splashColor: Colors.white.withOpacity(0.3),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Text(
                          "See More",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFCA2E55),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: _scrollLeft,
              ),
              Expanded(
                child: SizedBox(
                  height: 375,
                  child: ListView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    children: [
                      SizedBox(width: 35),
                      OfferSelectionWidget(
                        image: "assets/front_donut/fdonut5.png",
                        title: "Strawberry Wheel",
                        description:
                            "These Baked Strawberry Donuts are filled with fresh strawberries and rainbow sprinkles.",
                        newPrice: "₱76",
                        isFavInitial: true,
                      ),
                      OfferSelectionWidget(
                        image: "assets/front_donut/fdonut11.png",
                        title: "Chocolate Glaze",
                        description:
                            "Moist and fluffy baked chocolate donuts full of chocolate flavor.",
                        newPrice: "₱40",
                        isFavInitial: false,
                      ),
                      OfferSelectionWidget(
                        image: "assets/front_donut/fdonut9.png",
                        title: "Matcha Rainbow",
                        description:
                            "Moist and fluffy baked cotton candy flavored-donuts with a splash of colorful sprinkles.",
                        newPrice: "₱40",
                        isFavInitial: false,
                      ),
                      OfferSelectionWidget(
                        image: "assets/front_donut/fdonut10.png",
                        title: "Matcha Rainbow",
                        description:
                            "Moist and fluffy baked matcha donuts full of matcha flavor.",
                        newPrice: "₱40",
                        isFavInitial: false,
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: _scrollRight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CatalogPageDonuts extends StatefulWidget {
  const CatalogPageDonuts({super.key});

  @override
  _CatalogPageDonutsState createState() => _CatalogPageDonutsState();
}

class _CatalogPageDonutsState extends State<CatalogPageDonuts> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(35, 0, 35, 0),
            child: Container(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 20,
                runSpacing: 5,
                children: [
                  Text(
                    "Donuts",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        debugPrint("See More clicked");
                      },
                      borderRadius: BorderRadius.circular(20),
                      splashColor: Colors.white.withOpacity(0.3),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Text(
                          "See More",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFCA2E55),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: _scrollLeft,
              ),
              Expanded(
                child: SizedBox(
                  height: 235,
                  child: ListView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('products')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('No donuts found.'));
                          }
                          final donuts = snapshot.data!.docs;
                          final images = [
                            "assets/side_donut/sdonut8.png",
                            "assets/side_donut/sdonut7.png",
                            "assets/side_donut/sdonut6.png",
                          ];
                          return Row(
                            children: List.generate(donuts.length, (index) {
                              final donut = donuts[index];
                              final image = images[index % images.length];
                              return DonutSelectionWidget(
                                image: image,
                                title: donut['name'],
                                newPrice: '₱${donut['price'].toStringAsFixed(2)}',
                              );
                            }),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: _scrollRight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
