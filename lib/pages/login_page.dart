import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:itelec_quiz_one/components/buttons.dart';
import 'package:itelec_quiz_one/pages/catalog_page.dart';
import 'package:itelec_quiz_one/pages/registration_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:toastification/toastification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/pages/admin/manage_orders.dart';

import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? _errorText; // Add a variable to store error messages

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  Future<void> _checkIfLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getInt('role'); // Retrieve role from shared preferences

    if (user != null && role != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        if (role == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ManageOrdersPage()),
          );
          return;
        } else if (role == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CatalogPage()),
          );
          return;
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CatalogPage()),
      );
    }
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Retrieve the user document from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists || userDoc['is_deleted'] == true) {
          // If user document doesn't exist or is marked as deleted
          await FirebaseAuth.instance.signOut(); // Prevent access

          String errorMessage = 'Invalid credentials.';
          print('This account has been deactivated.');

          setState(() {
            _errorText = errorMessage;
          });

          toastification.show(
            context: context,
            title: Text('Login Failed'),
            description: Text(errorMessage),
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 4),
          );

          return;
        }

        // Continue if the user document is valid
        String username = userDoc['username'];
        int role = userDoc['role'];

        // Save the username in SharedPreferences for session-wide access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setInt('role', role);

        setState(() {
          _errorText = null; // Clear the error
        });

        toastification.show(
          context: context,
          title: Text('Login Successful'),
          description: Text('Welcome back!'),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 4),
        );

        // Navigate based on role
        if (role == 2 || role == 3) {
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
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided.';
        } else {
          errorMessage = 'Invalid credentials.';
        }

        setState(() {
          _errorText = errorMessage;
        });

        toastification.show(
          context: context,
          title: Text('Login Failed'),
          description: Text(errorMessage),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 4),
        );
      } catch (e, stackTrace) {
        print('Unexpected error: $e');
        print('Stack trace: $stackTrace');
        setState(() {
          _errorText = 'An unexpected error occurred.';
        });
        toastification.show(
          context: context,
          title: Text('Error logging in'),
          description: Text('An unexpected error occurred.'),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 4),
        );
      }
    }
  }

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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Login Page",
      debugShowCheckedModeBanner: false, // Remove debug ribbon
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFDE5CC),
        fontFamily: 'Inter', // Apply Inter font
      ),
      home: Scaffold(
        appBar: AppBarWithMenuAndTitle(title: "Login"),
        drawer: GuestDrawer(),
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
                        _buildTextField(
                            "Email", "Your email", true, emailController,
                            validator: _validateEmail),
                        SizedBox(height: 10),
                        _buildPasswordField("Password", "Your password", true,
                            validator: _validatePassword),
                        SizedBox(height: 10),
                        if (_errorText != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              _errorText!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
                        GradientButton(text: "Log in", onPressed: _loginUser),
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
                        text: ' *',
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
      {String? Function(String?)? validator}) {
    bool _obscureText = true;

    return StatefulBuilder(
      builder: (context, setState) {
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
                            text: ' *',
                            style: TextStyle(color: Color(0xFFEC2023)),
                          ),
                        ]
                      : [],
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController, // Use class-level controller
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.black26),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Color(0xFFEF4F56),
                        width: 2.0), // Highlight color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.black26),
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
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                cursorColor: Color(0xFFCA2E55),
                style: TextStyle(fontFamily: 'Inter', color: Colors.black),
                validator: validator,
              ),
            ],
          ),
        );
      },
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
  void initState() {
    super.initState();
    _loadRememberMeState(); // Load the saved state on initialization
  }

  Future<void> _loadRememberMeState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isChecked = prefs.getBool('rememberMe') ?? false;
    });
  }

  Future<void> _saveRememberMeState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _isChecked, // Bind to the state variable
          onChanged: (value) {
            setState(() {
              _isChecked = value!; // Update the state on change
              _saveRememberMeState(_isChecked); // Save the state persistently
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
