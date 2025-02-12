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
        body: SingleChildScrollView(
          child: Column(
            children: [
              // HomeTxtFieldSection(),
              RightPink(),
              TxtCenter(),
              BtnFieldSection()
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

class DrwerHeader extends StatefulWidget {
  @override
  _Drwheader createState() => _Drwheader();
}

class _Drwheader extends State<DrwerHeader> {
  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(color: Colors.black54),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/half_donut.png'),
            radius: 40,
          ),
          SizedBox(height: 20),
          Text(
            "ITELEC4C",
            style: TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          )
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
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Home Page
          ListTile(
            title: Text("Get Started"),
            leading: Icon(Icons.add_box_sharp),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyApp())),
          ),
          // Page 1 - Registration
          ListTile(
            title: Text("Registration"),
            leading: Icon(Icons.add_box_sharp),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => RegistrationPage())),
          ),
          // Page 4 - Free Page/Login
          ListTile(
            title: Text("Login"),
            leading: Icon(Icons.add_box_sharp),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginPage())),
          ),

          // Page 2 - Catalog
          ListTile(
            title: Text("Catalog"),
            leading: Icon(Icons.add_box_sharp),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => CatalogPage())),
          ),
          // Page 3 - Product
          ListTile(
            title: Text("Product"),
            leading: Icon(Icons.add_box_sharp),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProductPage())),
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
      width: double.infinity,
      height: MediaQuery.of(context).size.height, // Full height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space images apart
        children: [
          // Left-side image
          Container(
            width: 200, // Adjust width
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
            width: MediaQuery.of(context).size.width * 0.5, // Adjust width
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

class TxtCenter extends StatelessWidget {
  const TxtCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Container(
        child: Column(
          children: [
            Text(
              "DoNut Stop",
              style: TextStyle(
                fontSize: 84,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(254, 86, 133, 1),
              ),
            ),
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqconsequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu um.",
              style: TextStyle(
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
              onPressed: () {},
              child: Text("Get Started",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.white,
                    color: Color.fromRGBO(254, 86, 133, 1),
                  )),
            )),
          ],
        ));
  }
}
