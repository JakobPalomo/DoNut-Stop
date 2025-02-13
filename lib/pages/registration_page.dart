import 'package:flutter/material.dart';

import '../main.dart';

void main() {
  runApp(const RegistrationPage());
}

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Donut Stop Registration",
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Inter',
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
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
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Register",
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
        backgroundColor: const Color(0xFFFCE5CD),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const RegPageImgSection(),
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Let's Sign Up!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF462521),
                      ),
                    ),
                    const RegPageTxtFieldSection(),
                    const RegPageBtnFieldSection(),
                  ],
                ),
              ),
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

class RegPageImgSection extends StatelessWidget {
  const RegPageImgSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child:
          Image.asset('assets/main_logo.png', height: 400, fit: BoxFit.cover),
    );
  }
}

class RegPageTxtFieldSection extends StatelessWidget {
  const RegPageTxtFieldSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child:
                      _buildTextField("First name ", "Your first name", true)),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildTextField("Last name ", "Your last name", true)),
            ],
          ),
          _buildTextField("Username ", "Your username", true),
          _buildTextField("Email address ", "Your email address", true),
          _buildPasswordField("Password ", "Your password", true),
          _buildPasswordField(
              "Confirm password ", "Confirm your password", true),
          Row(
            children: [
              Expanded(
                  child: _buildTextField("District ", "Your district", true)),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField("City ", "Your city", true)),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField("ZIP ", "Your ZIP", true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold),
              children: isRequired
                  ? [
                      TextSpan(
                        text: '*',
                        style: TextStyle(color: Color(0xFFEC2023)),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, String hint, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold),
              children: isRequired
                  ? [
                      TextSpan(
                        text: '*',
                        style: TextStyle(color: Color(0xFFEC2023)),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: const Icon(Icons.visibility_off),
            ),
          ),
        ],
      ),
    );
  }
}

class RegPageBtnFieldSection extends StatelessWidget {
  const RegPageBtnFieldSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton("Cancel", Colors.white, Color(0xFFDC345E), () {}),
              const SizedBox(width: 10),
              _buildButton("Sign Up", Color(0xFFDC345E), Colors.white, () {}),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              // Add navigation to login page here
            },
            child: RichText(
              text: const TextSpan(
                text: "Already have an account? ",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
                children: [
                  TextSpan(
                    text: "Sign up",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(text,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter')),
      ),
    );
  }
}
