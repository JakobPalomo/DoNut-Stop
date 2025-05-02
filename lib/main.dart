import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:firebase_core/firebase_core.dart';
import 'package:itelec_quiz_one/pages/admin/manage_orders.dart';
import 'package:itelec_quiz_one/pages/admin/manage_products.dart';
import 'package:itelec_quiz_one/pages/admin/manage_users.dart';
import 'package:itelec_quiz_one/pages/catalog_page.dart';
import 'package:itelec_quiz_one/pages/login_page.dart';
import 'package:itelec_quiz_one/pages/product_page.dart';
import 'package:itelec_quiz_one/pages/registration_page.dart';
import 'package:itelec_quiz_one/pages/product_management_page.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:itelec_quiz_one/pages/transaction_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';
import 'package:itelec_quiz_one/utils/auth_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure plugin initialization

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyANrhbfi3htnVLnZzLGgRXED5yH3YotKy4",
        authDomain: "donut-stop.firebaseapp.com",
        projectId: "donut-stop",
        storageBucket: "donut-stop.firebasestorage.app",
        messagingSenderId: "357182777996",
        appId: "1:357182777996:web:a9547e3826d3c0e906a9a9",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  //debugPaintSizeEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("Post-frame callback executed");
      await Future.delayed(Duration.zero, () async {
        await _checkLoginStatus(context);
        await _checkRememberMe(context);
      });
    });
  }

  Future<void> _checkRememberMe(BuildContext context) async {
    print("Checking Remember Me...");
    final prefs = await SharedPreferences.getInstance();
    final isRemembered = prefs.getBool('rememberMe') ?? false;
    print("Remember Me: $isRemembered");
    if (isRemembered) {
      print("Navigating based on user role...");
      final userRole =
          prefs.getInt('role') ?? 0; // Assuming role is saved as an integer
      if (userRole == 3) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ManageOrdersPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CatalogPage()),
        );
      }
    }
  }

  Future<void> _checkLoginStatus(BuildContext context) async {
    print("Checking Login Status...");
    await checkIfLoggedIn(context); // Call the checkIfLoggedIn function
    print("Login Status Checked");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "DoNut Stop",
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          // Call navigation logic here
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            print("Post-frame callback executed");
            await _checkLoginStatus(context);
            await _checkRememberMe(context);
          });

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFFEDC690),
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
            drawer: GuestDrawer(),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(255, 225, 183, 1.0),
                    Color.fromRGBO(255, 225, 183, 1.0),
                    Colors.white,
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
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
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
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
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
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -35,
            top: -35, // Move the image upwards
            child: Transform.rotate(
              angle: 0, // Adjust the angle as needed
              child: Transform.scale(
                scale: 1.1, // Adjust the scale as needed
                child: Container(
                  width: 250,
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/index_donut1.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Right-side image
          Positioned(
            right: 10,
            top: -30, // Move the image upwards
            child: Transform.rotate(
              angle: -1, // Adjust the angle as needed
              child: Transform.scale(
                scale: 1.8, // Adjust the scale as needed
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 250,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/half_donut.png'), // Right-side image
                      fit: BoxFit.contain, // Adjust as needed
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
                padding: const EdgeInsets.fromLTRB(5, 200, 5, 0),
                child: Image.asset(
                  'assets/homepage_logo.png',
                  width: 500,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          // Positioned image
          Positioned(
            left: 0,
            right: 0,
            top: -30,
            child: Align(
              alignment: Alignment.topCenter,
              child: Transform.rotate(
                angle: .2, // Adjust the angle as needed
                child: Transform.scale(
                  scale: 1.8, // Adjust the scale as needed
                  child: Image.asset(
                    'assets/index_donuts.png',
                    width: 500,
                    height: 200,
                    fit: BoxFit.contain,
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

class TxtCenter extends StatelessWidget {
  const TxtCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 40, right: 40, bottom: 25),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Container(
          constraints: BoxConstraints(maxWidth: 800),
          child: Text(
            "At Donut Stop, every bite is a moment of pure joy! Whether you're craving a classic glazed, a chocolate-filled delight, or a unique new flavor. Life is too short to skip dessert, so why stop? Indulge in happiness, one donut at a time!",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFAD5F25),
            ),
            textAlign: TextAlign.justify,
          ),
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
      child: Container(
        width: double.infinity, // Ensures it stretches to available width
        alignment: Alignment.center, // Centers the content
        constraints: BoxConstraints(maxWidth: 800), // Max width of 800px
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Container(
                width: double.infinity, // Take full width if wrapped
                constraints: BoxConstraints(maxWidth: 200), // Limit max width
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF7171), Color(0xFFDC345E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(100),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 25),
                  ),
                  child: Center(
                    child: Text(
                      "Get Started",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => TransactionPage(
            //                 accountName: "Ira Customer",
            //                 amountPaid: 150.00,
            //                 orders: "somehting",
            //                 refNo: "123456789",
            //                 dateTime: "April 28, 2025, 10:27 AM",
            //               )),
            //     );
            //   },
            //   child: Text("Transaction Page"),
            // ),
          ],
        ),
      ),
    );
  }
}
