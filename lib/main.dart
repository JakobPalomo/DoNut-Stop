import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/pages/catalog_page.dart';
import 'package:itelec_quiz_one/pages/login_page.dart';
import 'package:itelec_quiz_one/pages/product_page.dart';
import 'package:itelec_quiz_one/pages/registration_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "DoNut Stop",
      debugShowCheckedModeBanner: false, // Remove debug ribbon
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFEDC690), // Background color
          elevation: 0,
          scrolledUnderElevation: 0,
            title: Row(
            children: [
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
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Home",
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF462521)),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(255, 225, 183, 1.0),
                Color.fromRGBO(255, 225, 183, 1.0),
                Colors.white, // Deep Yellow/Orange
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                RightPink(),
                MidDonut(),
                TxtCenter(),
                BtnFieldSection(),
              ],
            ),
          ),
        ),
        drawer: Drawer(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: ListView(
            children: [DrwerHeader(), DrwListView()],
          ),
        ),
      ),
    );
  }
}

class DrwerHeader extends StatefulWidget {
  @override
  _Drwheader createState() => _Drwheader();
}

class _Drwheader extends State<DrwerHeader> {
  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(color: Color(0xFFFFE1B7)),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
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
          Center(
            child: Image.asset(
              'assets/main_logo.png',
              width: 220,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class DrwListView extends StatefulWidget {
  @override
  _DrwListView createState() => _DrwListView();
}

class _DrwListView extends State<DrwListView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          // Home Page
          ListTile(
            title: Text(
              "Home",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: Color(0xFF462521),
                fontSize: 16,
              ),
            ),
            leading: Container(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: Image.asset(
                'assets/icons/home.png',
                width: 24,
                height: 24,
              ),
            ),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyApp())),
          ),
          // Page 1 - Registration
          ListTile(
            title: Text(
              "Our Donuts",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: Color(0xFF462521),
                fontSize: 16,
              ),
            ),
            leading: Container(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: Image.asset(
                'assets/icons/catalog.png',
                width: 24,
                height: 24,
              ),
            ),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => CatalogPage())),
          ),
          // Page 4 - Free Page/Login
          ListTile(
            title: Text(
              "About Donut",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: Color(0xFF462521),
                fontSize: 16,
              ),
            ),
            leading: Container(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: Image.asset(
                'assets/icons/about.png',
                width: 24,
                height: 24,
              ),
            ),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProductPage())),
          ),

          // Page 2 - Catalog
          ListTile(
            title: Text(
              "Register",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: Color(0xFF462521),
                fontSize: 16,
              ),
            ),
            leading: Container(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: Image.asset(
                'assets/icons/register.png',
                width: 24,
                height: 24,
              ),
            ),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => RegistrationPage())),
          ),
          // Page 3 - Product
          ListTile(
            title: Text(
              "Login",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: Color(0xFF462521),
                fontSize: 16,
              ),
            ),
            leading: Container(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: Image.asset(
                'assets/icons/login.png',
                width: 24,
                height: 24,
              ),
            ),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginPage())),
          ),
        ],
      ),
    );
  }
}

class HomeTxtFieldSection extends StatelessWidget {
  const HomeTxtFieldSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                  child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "HOME PAGE",
                    hintMaxLines: 2,
                    hintStyle: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class RightPink extends StatelessWidget {
  const RightPink({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 200,
                height: 130,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/index_donut1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          // Right-side image
          Positioned(
            right: 10,
            top: -30, // Move the image upwards
            child: Transform.rotate(
              angle: -1, // Adjust the angle as needed
              child: Transform.scale(
                scale: 1.5, // Adjust the scale as needed
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 250,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/half_donut.png'), // Right-side image
                      fit: BoxFit.cover, // Adjust as needed
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MidDonut extends StatelessWidget {
  const MidDonut({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Stack(
         clipBehavior: Clip.none, // Allow overflow
        children: [
          // Other elements
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 180),
                child: Image.asset(
                  'assets/homepage_logo.png',
                  width: 500,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          // Positioned image
          Positioned(
            left: 0,
            child: Transform.rotate(
              angle: .2, // Adjust the angle as needed
              child: Transform.scale(
                scale: 1.2, // Adjust the scale as needed
                child: Image.asset(
                  'assets/index_donuts.png',
                  width: 500,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TxtCenter extends StatelessWidget {
  const TxtCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 40, right: 40), // Remove top padding
      child: Container(
        child: Column(
          children: [
            Text(
              "At Donut Stop, every bite is a moment of pure joy! Whether you're craving a classic glazed, a chocolate-filled delight, or a unique new flavor. Life is too short to skip dessert, so why stop? Indulge in happiness, one donut at a time!",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFAD5F25),
                fontFamily: 'Inter', // Apply Inter font
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}

class BtnFieldSection extends StatelessWidget {
  const BtnFieldSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7171), Color(0xFFDC345E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
