import 'package:flutter/material.dart';

import '../main.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Login Page Module",
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFE0B6), // Set background color
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
                width: 70,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  image: DecorationImage(
                    image: AssetImage("assets/mini_logo.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "Login",
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF462521)),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [LoginPageBtnFieldSection()],
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

class LoginPageBtnFieldSection extends StatelessWidget {
  const LoginPageBtnFieldSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyApp())),
                  icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
                  label: Text("Back Home")))
        ],
      ),
    );
  }
}
