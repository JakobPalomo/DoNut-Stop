import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:itelec_quiz_one/pages/catalog_page.dart';
import 'package:itelec_quiz_one/pages/registration_page.dart';

import '../main.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    String? _validateRequiredField(String? value) {
      if (value == null || value.isEmpty) {
        return 'This field is required';
      }
      return null;
    }

    return MaterialApp(
      title: "Login Page Module",
      debugShowCheckedModeBanner: false, // Remove debug ribbon
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFDE5CC),
        fontFamily: 'Inter', // Apply Inter font
      ),
      home: Scaffold(
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
                    "Login",
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
        drawer: Drawer(
          child: ListView(
            children: [DrwerHeader(), DrwListView()],
          ),
        ),
        body: Container(
          width: double.infinity, // Ensures the gradient covers the full width
          height: double.infinity, // Ensures it covers the full height
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
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/main_logo0.png"),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Welcome, User!",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF462521),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        _buildTextField("Username ", "Your username", true,
                            usernameController,
                            validator: _validateRequiredField,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50)
                            ]),
                        SizedBox(height: 10),
                        _buildPasswordField("Password ", "Your password", true,
                            passwordController,
                            validator: _validateRequiredField),
                        SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 300) {
                                // Small screen: Wrap items to prevent overflow
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyCheckbox(),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        "Forgot password?",
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: Color(0xFF686868),
                                        ),
                                        softWrap: true, // Allow wrapping
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                // Larger screen: Maintain spaceBetween
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyCheckbox(),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        "Forgot password?",
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: Color(0xFF686868),
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity, // Take full width if wrapped
                          constraints: BoxConstraints(maxWidth: 200),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF7171), Color(0xFFDC345E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CatalogPage()),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 30),
                            ),
                            child: Text(
                              "Log in",
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Color(0xFF686868))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "or Sign in with",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF686868),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(child: Divider(color: Color(0xFF686868))),
                          ],
                        ),
                        SizedBox(height: 20),
                        Container(
                            width: double.infinity,
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 20,
                              runSpacing: 10,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    iconSize: 22,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    side:
                                        BorderSide(color: Colors.grey.shade300),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 20),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CatalogPage()),
                                    );
                                  },
                                  icon: Icon(FontAwesomeIcons.facebook,
                                      color: Colors.blue),
                                  label: Text(
                                    "Facebook",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color(0xFF686868),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    iconSize: 22,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    side:
                                        BorderSide(color: Colors.grey.shade300),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 20),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CatalogPage()),
                                    );
                                  },
                                  icon: Icon(FontAwesomeIcons.google,
                                      color: Colors.red),
                                  label: Text(
                                    "Google",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color(0xFF686868),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(height: 20),
                        MouseRegion(
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: const TextStyle(
                                color: Color(0xFF686868),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: "Sign up",
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
                                            builder: (context) =>
                                                RegistrationPage()),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    bool isRequired,
    TextEditingController controller, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
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
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Colors.white), // Default border color
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: Color(0xFFCA2E55), width: 2.0), // Highlight color
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Colors.white), // Normal border color
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            cursorColor: Color(0xFFCA2E55), // Changes the cursor color
            style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.black), // Text color inside the field
            validator: validator,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, String hint, bool isRequired,
      TextEditingController controller,
      {String? Function(String?)? validator}) {
    return PasswordField(
      label: label,
      hint: hint,
      isRequired: isRequired,
      isBorderWhite: true,
      validator: validator,
    );
  }
}

class MyCheckbox extends StatefulWidget {
  @override
  _MyCheckboxState createState() => _MyCheckboxState();
}

class _MyCheckboxState extends State<MyCheckbox> {
  bool _isChecked = false; // Variable to store checkbox state

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _isChecked, // Bind to the state variable
          onChanged: (value) {
            setState(() {
              _isChecked = value!; // Update the state on change
            });
          },
          activeColor: Color(0xFFCA2E55), // Color when active
          checkColor: Color(0xFFCA2E55), // Checkmark color
          fillColor: MaterialStateProperty.all(Colors.white), // Box color
          side: BorderSide.none, // Remove outline
        ),
        Text(
          "Remember me",
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Color(0xFF686868),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
