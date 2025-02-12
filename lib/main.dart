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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "DoNut Stop",
      home: Scaffold(
        appBar: AppBar(
          title: Text("DoNut Stop"),
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
                width: 24,
                height: 24,
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
          // SizedBox(height: 20),
          // Text(
          //   "ITELEC4C",
          //   style: TextStyle(
          //       color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          // )
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
      padding: const EdgeInsets.only(left: 16.0, top: 16.0),
      child: Column(
        children: [
          // Home Page
          ListTile(
            title: Text("Home"),
            leading: Image.asset(
              'assets/icons/home.png',
              width: 24,
              height: 24,
            ),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyApp())),
          ),
          // Page 1 - Registration
          ListTile(
            title: Text("Our Donuts"),
            leading: Image.asset(
              'assets/icons/catalog.png',
              width: 24,
              height: 24,
            ),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => CatalogPage())),
          ),
          // Page 4 - Free Page/Login
          ListTile(
            title: Text("About Donut"),
            leading: Image.asset(
              'assets/icons/about.png',
              width: 24,
              height: 24,
            ),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => ProductPage())),
          ),

          // Page 2 - Catalog
          ListTile(
            title: Text("Register"),
            leading: Image.asset(
              'assets/icons/register.png',
              width: 24,
              height: 24,
            ),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => RegistrationPage())),
          ),
          // Page 3 - Product
          ListTile(
            title: Text("Login"),
            leading: Image.asset(
              'assets/icons/login.png',
              width: 24,
              height: 24,
            ),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) =>LoginPage())),
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
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space images apart
        children: [
          // Left-side image
          Container(
            width: 150,
            height: 150,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/index_donut1.png'), // Replace with actual left-side image
                fit: BoxFit.cover, // Adjust as needed
              ),
            ),
          ),

          // Right-side image
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: 200,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/half_donut.png'), // Right-side image
                fit: BoxFit.cover, // Adjust as needed
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
        child: Column(
          children: [
            Image.asset(
              'assets/index_donuts.png',
              width: 500,
              height: 250,
              fit: BoxFit.cover,
            ),
            Image.asset(
              'assets/homepage_logo.png',
              width: 500,
              height: 200,
              fit: BoxFit.cover,
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
      padding: EdgeInsets.all(20),
      child: Container(
        child: Column(
          children: [
            Text(
"At Donut Stop, every bite is a moment of pure joy! Whether you're craving a classic glazed, a chocolate-filled delight, or a unique new flavor. Life is too short to skip dessert, so why stop? Indulge in happiness, one donut at a time!",             style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(254, 86, 133, 1),
              ),
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
        padding: EdgeInsets.all(30),

        child: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(254, 86, 133, 1),
                  foregroundColor: Colors.white, // Text color
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              onPressed: () {},
                child: Text("Get Started",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,

                  )
                ),
            ),
            ),
          ],
        ));
  }
}
