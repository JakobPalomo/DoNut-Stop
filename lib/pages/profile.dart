import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';

class ProfilePage extends StatefulWidget {
  final bool isEditing;

  const ProfilePage({
    this.isEditing = false,
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController donutNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "${widget.isEditing ? "Edit" : "Add"} Donut",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFE0B6),
        fontFamily: 'Inter',
      ),
      home: Scaffold(
        backgroundColor: Color(0xFFFFE0B6),
        appBar: AppBarWithMenuAndTitle(title: "My Profile"),
        drawer: UserDrawer(), // or AdminDrawer() or EmployeeDrawer()
        body: Column(
          children: [
            // Profile Image Section (Change this)
            Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Stack(children: [
                  widget.isEditing
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/front_donut/fdonut1.png',
                            width: 250,
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Column(
                          children: [
                            Text(
                              "Add an image of the product",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFC7A889),
                              ),
                            ),
                            SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/icons/no_image.png',
                                width: 150,
                                height: 150,
                                fit: BoxFit.contain,
                              ),
                            )
                          ],
                        ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFFCA2E55),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        widget.isEditing ? Icons.add : Icons.edit,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  )
                ])),
            SizedBox(height: 20),

            // Profile Details Section
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
                        RichText(
                          text: TextSpan(
                              text: "Username",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                              ),
                              children: []),
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
