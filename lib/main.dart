import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/pages/about_page.dart';
import 'package:itelec_quiz_one/pages/free_page.dart';
import 'package:itelec_quiz_one/pages/products_page.dart';

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
              BckgroundCenter(),
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
            backgroundImage: AssetImage('assets/test.jpg'),
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
            title: Text("Home"),
            leading: Icon(Icons.add_box_sharp),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyApp())),
          ),
          // Page 1 - Registration
          ListTile(
            title: Text("Registration"),
            leading: Icon(Icons.add_box_sharp),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => registration_page())),
          ),
          // Page 2 - Products
          ListTile(
            title: Text("Products"),
            leading: Icon(Icons.add_box_sharp),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => products_page())),
          ),
          // Page 3 - About
          ListTile(
            title: Text("About"),
            leading: Icon(Icons.add_box_sharp),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => about_page())),
          ),
          // Page 4 - Free Page/Contact
          ListTile(
            title: Text("Contact"),
            leading: Icon(Icons.add_box_sharp),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => free_page())),
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

class BckgroundCenter extends StatelessWidget {
  const BckgroundCenter({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/test.jpg'),
        ),
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
