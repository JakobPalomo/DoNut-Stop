import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/pages/product_page.dart';

import '../main.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Catalog Page Module",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFE0B6),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFEDC690), // Background color
          elevation: 0, // Remove shadow
          scrolledUnderElevation: 0,
          title: Row(
            children: [
              // Square Image on the Left
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  image: DecorationImage(
                    image: AssetImage("assets/mini_logo.png"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Search Bar
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      cursorColor: Colors.white,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF2F090B),
                        hintText: "Search products",
                        hintStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 15, right: 10),
                          child: Icon(Icons.search,
                              color: Colors.white, size: 18.0),
                        ), // Search icon
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(30), // Rounded edges
                          borderSide: BorderSide.none, // No border
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              CatalogPageTitleContainer(),
              CatalogPageTodaysOffers(),
              CatalogPageDonuts(),
              SizedBox(height: 30)
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: [DrwerHeader(), DrwListView()],
          ),
        ),
      ),
    );
  }
}

class CatalogPageTitleContainer extends StatelessWidget {
  const CatalogPageTitleContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(35, 35, 35, 25),
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
              "Welcome to Donut Stop!",
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF462521)),
            ),
            SizedBox(height: 5),
            Text(
              "Order your favourite donuts from here!",
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF665A49)),
            ),
          ],
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
  final String image, title, description, oldPrice, newPrice;
  final bool isFavInitial;

  OfferSelectionWidget({
    required this.image,
    required this.title,
    required this.description,
    required this.oldPrice,
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductPage()),
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
                            Text(
                              widget.oldPrice,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Color(0xFF665A49),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
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
                    MaterialPageRoute(builder: (context) => ProductPage()),
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
                            color: Color(0xFFCA2E55),
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
                    MaterialPageRoute(builder: (context) => ProductPage()),
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

class CatalogPageTodaysOffers extends StatelessWidget {
  const CatalogPageTodaysOffers({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(35, 0, 0, 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Offers & See More
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 35, 0),
            child: Wrap(
              alignment: WrapAlignment
                  .start, // Centers buttons inside the full-width container
              spacing: 20, // Horizontal spacing between buttons
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
                  color: Colors.transparent, // Ensures no background color
                  borderRadius: BorderRadius.circular(8), // Rounded edges
                  child: InkWell(
                    onTap: () {
                      debugPrint("See More clicked");
                    },
                    borderRadius: BorderRadius.circular(20),
                    splashColor:
                        Colors.white.withOpacity(0.3), // White ripple effect
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          SizedBox(height: 10),
          // Flavors Chips
          ToggleChipsRow(),
          SizedBox(height: 10),
          // Selections
          SizedBox(
            height: 375,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  OfferSelectionWidget(
                    image: "assets/front_donut/fdonut5.png",
                    title: "Strawberry Wheel",
                    description:
                        "These Baked Strawberry Donuts are filled with fresh strawberries and rainbow sprinkles.",
                    oldPrice: "₱90",
                    newPrice: "₱76",
                    isFavInitial: true,
                  ),
                  OfferSelectionWidget(
                    image: "assets/front_donut/fdonut11.png",
                    title: "Chocolate Glaze",
                    description:
                        "Moist and fluffy baked chocolate donuts full of chocolate flavor.",
                    oldPrice: "₱50",
                    newPrice: "₱40",
                    isFavInitial: false,
                  ),
                  OfferSelectionWidget(
                    image: "assets/front_donut/fdonut9.png",
                    title: "Matcha Rainbow",
                    description:
                        "Moist and fluffy baked cotton candy flavored-donuts with a splash of colorful sprinkles.",
                    oldPrice: "₱50",
                    newPrice: "₱40",
                    isFavInitial: false,
                  ),
                  OfferSelectionWidget(
                    image: "assets/front_donut/fdonut10.png",
                    title: "Matcha Rainbow",
                    description:
                        "Moist and fluffy baked matcha donuts full of matcha flavor.",
                    oldPrice: "₱50",
                    newPrice: "₱40",
                    isFavInitial: false,
                  ),
                  OfferSelectionWidget(
                    image: "assets/front_donut/fdonut1.png",
                    title: "Matcha Rainbow",
                    description:
                        "Moist and fluffy baked matcha donuts full of matcha flavor.",
                    oldPrice: "₱50",
                    newPrice: "₱40",
                    isFavInitial: false,
                  ),
                  OfferSelectionWidget(
                    image: "assets/front_donut/fdonut2.png",
                    title: "Matcha Rainbow",
                    description:
                        "Moist and fluffy baked matcha donuts full of matcha flavor.",
                    oldPrice: "₱50",
                    newPrice: "₱40",
                    isFavInitial: false,
                  ),
                  OfferSelectionWidget(
                    image: "assets/front_donut/fdonut3.png",
                    title: "Matcha Rainbow",
                    description:
                        "Moist and fluffy baked matcha donuts full of matcha flavor.",
                    oldPrice: "₱50",
                    newPrice: "₱40",
                    isFavInitial: false,
                  ),
                  OfferSelectionWidget(
                    image: "assets/front_donut/fdonut4.png",
                    title: "Matcha Rainbow",
                    description:
                        "Moist and fluffy baked matcha donuts full of matcha flavor.",
                    oldPrice: "₱50",
                    newPrice: "₱40",
                    isFavInitial: false,
                  ),
                  OfferSelectionWidget(
                    image: "assets/front_donut/fdonut5.png",
                    title: "Matcha Rainbow",
                    description:
                        "Moist and fluffy baked matcha donuts full of matcha flavor.",
                    oldPrice: "₱50",
                    newPrice: "₱40",
                    isFavInitial: false,
                  ),
                  OfferSelectionWidget(
                    image: "assets/front_donut/fdonut6.png",
                    title: "Matcha Rainbow",
                    description:
                        "Moist and fluffy baked matcha donuts full of matcha flavor.",
                    oldPrice: "₱50",
                    newPrice: "₱40",
                    isFavInitial: false,
                  ),
                  OfferSelectionWidget(
                    image: "assets/front_donut/fdonut7.png",
                    title: "Matcha Rainbow",
                    description:
                        "Moist and fluffy baked matcha donuts full of matcha flavor.",
                    oldPrice: "₱50",
                    newPrice: "₱40",
                    isFavInitial: false,
                  ),
                  OfferSelectionWidget(
                    image: "assets/front_donut/fdonut8.png",
                    title: "Matcha Rainbow",
                    description:
                        "Moist and fluffy baked matcha donuts full of matcha flavor.",
                    oldPrice: "₱50",
                    newPrice: "₱40",
                    isFavInitial: false,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          // Buttons
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 35, 0),
            child: Container(
              width: double
                  .infinity, // Ensures it spans the full width of the screen
              alignment: Alignment.center, // Centers content inside
              child: Wrap(
                alignment: WrapAlignment
                    .center, // Centers buttons inside the full-width container
                spacing: 20, // Horizontal spacing between buttons
                runSpacing: 10, // Vertical spacing when wrapped
                children: [
                  // Back to Top Button
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      side: BorderSide(color: Color(0xFFEF4F56)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 18, horizontal: 50),
                    ),
                    child: Text(
                      "Back to Top",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFCA2E55),
                      ),
                    ),
                  ),

                  // More Today's Offers Button with Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF7171), Color(0xFFDC345E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 18, horizontal: 30),
                      ),
                      child: Text(
                        "More Today's Offers",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CatalogPageDonuts extends StatelessWidget {
  const CatalogPageDonuts({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(35, 0, 0, 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Donuts & See More
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 35, 0),
            child: Wrap(
              alignment: WrapAlignment
                  .start, // Centers buttons inside the full-width container
              spacing: 20, // Horizontal spacing between buttons
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
                  color: Colors.transparent, // Ensures no background color
                  borderRadius: BorderRadius.circular(8), // Rounded edges
                  child: InkWell(
                    onTap: () {
                      debugPrint("See More clicked");
                    },
                    borderRadius: BorderRadius.circular(20),
                    splashColor:
                        Colors.white.withOpacity(0.3), // White ripple effect
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          SizedBox(height: 10),
          // Flavors Chips
          ToggleChipsRow(),
          SizedBox(height: 10),
          // Selections
          SizedBox(
            height: 235,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  DonutSelectionWidget(
                    image: "assets/side_donut/sdonut8.png",
                    title: "Chocolate Cherry",
                    newPrice: "₱50",
                  ),
                  DonutSelectionWidget(
                    image: "assets/side_donut/sdonut7.png",
                    title: "Strawberry Rain",
                    newPrice: "₱65",
                  ),
                  DonutSelectionWidget(
                    image: "assets/side_donut/sdonut6.png",
                    title: "Purple Blast",
                    newPrice: "₱45",
                  ),
                  DonutSelectionWidget(
                    image: "assets/side_donut/sdonut5.png",
                    title: "Royal Ube",
                    newPrice: "₱45",
                  ),
                  DonutSelectionWidget(
                    image: "assets/side_donut/sdonut4.png",
                    title: "Matcha Rainbow",
                    newPrice: "₱45",
                  ),
                  DonutSelectionWidget(
                    image: "assets/side_donut/sdonut3.png",
                    title: "Clear Glaze",
                    newPrice: "₱45",
                  ),
                  DonutSelectionWidget(
                    image: "assets/side_donut/sdonut2.png",
                    title: "Purple Drip",
                    newPrice: "₱45",
                  ),
                  DonutSelectionWidget(
                    image: "assets/side_donut/sdonut1.png",
                    title: "Purple Scramble",
                    newPrice: "₱45",
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          // Buttons
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 35, 0),
            child: Container(
              width: double
                  .infinity, // Ensures it spans the full width of the screen
              alignment: Alignment.center,
              child: Wrap(
                alignment: WrapAlignment
                    .center, // Centers buttons inside the full-width container
                spacing: 20, // Horizontal spacing between buttons
                runSpacing: 10,
                children: [
                  // Back to Top Button
                  ElevatedButton(
                    onPressed: () => () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shadowColor: Colors.transparent, // No shadow effect
                      side: BorderSide(color: Color(0xFFEF4F56)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 18, horizontal: 50), // Bigger padding
                    ),
                    child: Text(
                      "Back to Top",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFCA2E55),
                      ),
                    ),
                  ),
                  // More Donuts Button with Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF7171), Color(0xFFDC345E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.transparent, // transparent background
                        shadowColor: Colors.transparent, // No shadow effect
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 18, horizontal: 30), // Bigger padding
                      ),
                      child: Text(
                        "More Donuts",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
