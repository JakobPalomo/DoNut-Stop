import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/pages/login_page.dart';
import 'package:flutter/services.dart'; 

import '../main.dart';

void main() {
  runApp(const RegistrationPage());
}
final TextEditingController firstNameController = TextEditingController();
final TextEditingController lastNameController = TextEditingController();
final TextEditingController usernameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController confirmPasswordController = TextEditingController();
final _formKey = GlobalKey<FormState>();
  
  // String? _validateConfirmPassword(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'Confirm password is required';
  //   }
  //   if (value != passwordController.text) {
  //     return 'Passwords do not match';
  //   }
  //   return null;
  // }
  String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegex.hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Donut Stop Registration",
      debugShowCheckedModeBanner: false, // Remove debug ribbon
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
        backgroundColor: const Color(0xFFFFE0B6),
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
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF462521),
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          const RegPageTxtFieldSection(),
                          const RegPageBtnFieldSection(),
                        ],
                      ),
                    ),
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
          Image.asset('assets/main_logo.png', height: 400, fit: BoxFit.contain),
    );
  }
}

class RegPageTxtFieldSection extends StatelessWidget {
  const RegPageTxtFieldSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
    key: _formKey, // Attach _formKey here
    child: Container(
      constraints: BoxConstraints(maxWidth: 800),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 320) {
                  // Large screen: Use Row for two fields side by side
                  return Row(
                    children: [
                      Expanded(
                        child: 
                        _buildTextField("First name", "Your first name", true, firstNameController),

                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                            "Last name", "Your last name", true,lastNameController),
                      ),
                    ],
                  );
                } else {
                  // Small screen: Use Column to stack fields
                  return Column(
                    children: [
                      _buildTextField("First name", "Your first name", true, firstNameController),
                      _buildTextField("Last name", "Your last name", true, lastNameController),
                    ],
                  );
                }
              },
            ),
          ),
          _buildTextField("Username ", "Your username", true, usernameController),
          _buildTextField("Email address ", "Your email address", true, emailController, validator: _validateEmail),
          _buildPasswordField("Password ", "Your password", true, passwordController),
          _buildPasswordField(
              "Confirm password ", "Confirm your password", true, confirmPasswordController),
          Container(
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 400) {
                  // Large screen: Use Row for two fields side by side
                  return Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              "District ", "Your district", true,null)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _buildTextField("City ", "Your city", true,null)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _buildTextField("ZIP ", "Your ZIP", true,null)),
                    ],
                  );
                } else {
                  // Small screen: Use Column to stack fields
                  return Column(
                    children: [
                      _buildTextField("District ", "Your district", true,null),
                      _buildTextField("City ", "Your city", true,null),
                      _buildTextField("ZIP ", "Your ZIP", true,null)
                    ],
                  );
                }
              },
            ),
          )
        ],
      ),
    )
    );
  }

  Widget _buildTextField(String label, String hint, bool isRequired, TextEditingController? controller, {String? Function(String?)? validator}) {
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
              fontWeight: FontWeight.bold,
            ),
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
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.black26),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFCA2E55), width: 2.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          cursorColor: Color(0xFFCA2E55),
          style: TextStyle(fontFamily: 'Inter', color: Colors.black),
          validator: validator,
        ),
      ],
    ),
  );
}


  Widget _buildPasswordField(String label, String hint, bool isRequired, TextEditingController passwordController) {
    return PasswordField(label: label, hint: hint, isRequired: isRequired,);
      // validator: _validateConfirmPassword,);
 }
}

class RegPageBtnFieldSection extends StatelessWidget {
  const RegPageBtnFieldSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center, // Centers content
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800), // Max width 800px
        child: Column(
          children: [
            Container(
                width: double.infinity, // Ensures full width
                child: Wrap(
                  alignment: WrapAlignment.center, // Ensures spacing works
                  spacing: 20, // Horizontal spacing between buttons
                  runSpacing: 10,
                  children: [
                    Expanded(
                      child: _buildCancelButton(
                          "Cancel", Colors.white, const Color(0xFFDC345E), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                        );
                      }),
                    ),
                    Expanded(
                      child: _buildSignUpButton("Sign Up", const Color(0xFFDC345E), Colors.white, () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        }
                      }),
                    ),
                  ],
                )),
            const SizedBox(height: 10),
            MouseRegion(
              child: RichText(
                text: TextSpan(
                  text: "Already have an account? ",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                  children: [
                    TextSpan(
                      text: "Login",
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        color: Color(0xFFCA2E55),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(
      String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        shadowColor: Colors.transparent,
        side: const BorderSide(color: Color(0xFFEF4F56)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 53),
        minimumSize: const Size(200, 50),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Color(0xFFCA2E55),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton(
      String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7171), Color(0xFFDC345E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 50),
          minimumSize: const Size(200, 50),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final bool isRequired;
  final bool isBorderWhite; // New parameter with default value false
  final String? Function(String?)? validator; 

  const PasswordField({
    Key? key,
    required this.label,
    required this.hint,
    required this.isRequired,
    this.isBorderWhite = false,
    this.validator,
  }) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    Color borderColor = widget.isBorderWhite ? Colors.white : Colors.black26;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: widget.label,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold),
              children: widget.isRequired
                  ? [
                      TextSpan(
                        text: '*',
                        style: TextStyle(color: Color(0xFFEC2023)),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            obscureText: _obscureText,
            decoration: InputDecoration(
              hintText: widget.hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: borderColor), // Dynamic border color
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: Color(0xFFEF4F56), width: 2.0), // Highlight color
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: borderColor), // Dynamic enabled border
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText; // Toggle visibility
                  });
                },
              ),
            ),
            cursorColor: Color(0xFFCA2E55),
            style: TextStyle(fontFamily: 'Inter', color: Colors.black),
            // validator: validator,
          ),
        ],
      ),
    );
  }
}