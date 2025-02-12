import 'package:flutter/material.dart';

import '../main.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Catalog Page Module",
      home: Scaffold(
        appBar: AppBar(
          title: Text('Catalog Page Module'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              CatalogPageTitleContainer(),
              CatalogPageTodaysOffers(),
              // CatalogPageDonuts(),
              CatalogPageBtnFieldSection(),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(child: Text('Menu')),
              ListTile(title: Text('Home'))
            ],
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
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome to Donut Stop!",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF462521)),
          ),
          SizedBox(height: 5),
          Text(
            "Order your favourite donuts from here!",
            style: TextStyle(fontSize: 14, color: Color(0xFF665A49)),
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
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Today's Offers",
                  style: TextStyle(fontSize: 20, color: Colors.black)),
              Text("See More",
                  style: TextStyle(fontSize: 14, color: Color(0xFFCA2E55))),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              _buildChip("Strawberry", Color(0xFFCA2E55), Colors.white),
              SizedBox(width: 8),
              _buildChip("Chocolate", Color(0xFFFFEEE1), Color(0xFF665A49)),
              SizedBox(width: 8),
              _buildChip("Matcha", Color(0xFFFFEEE1), Color(0xFF665A49)),
            ],
          ),
          SizedBox(height: 10),
          _buildOfferSelection(
              "assets/front_donut/fdonut5.png",
              "Strawberry Wheel",
              "These Baked Strawberry Donuts are filled with fresh strawberries and rainbow sprinkles.",
              "₱90",
              "₱76",
              true),
          _buildOfferSelection(
              "assets/front_donut/fdonut11.png",
              "Chocolate Glaze",
              "Moist and fluffy baked chocolate donuts full of chocolate flavor.",
              "₱50",
              "₱40",
              false),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 14)),
    );
  }

  Widget _buildOfferSelection(String image, String title, String description,
      String oldPrice, String newPrice, bool isFav) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.asset(image,
                        width: double.infinity, fit: BoxFit.cover),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: Color(0xFFCA2E55),
                        ),
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
                Text(title,
                    style: TextStyle(fontSize: 16, color: Color(0xFF462521))),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Color(0xFF665A49)),
                ),
                Row(
                  children: [
                    Text(oldPrice,
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF665A49),
                            decoration: TextDecoration.lineThrough)),
                    SizedBox(width: 5),
                    Text(newPrice,
                        style: TextStyle(fontSize: 22, color: Colors.black)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CatalogPageBtnFieldSection extends StatelessWidget {
  const CatalogPageBtnFieldSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyApp())),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Color(0xFFEF4F56)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child:
                Text("Back to Top", style: TextStyle(color: Color(0xFFCA2E55))),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: LinearGradient(
                colors: [Color(0xFFFF7171), Color(0xFFDC345E)],
              ).colors.last,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: Text("More Today's Offers",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
