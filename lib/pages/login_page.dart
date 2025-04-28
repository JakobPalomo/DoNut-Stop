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
import 'package:itelec_quiz_one/utils/auth_utils.dart';
import 'package:itelec_quiz_one/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    checkIfLoggedIn(context);
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
          errorMessage = 'Wrong password provided or sign in with Google.';
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

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception("Google sign-in failed.");
      }

      // Check if the user already exists in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // Register the user in Firestore if they don't exist
        await registerUserGoogle(
          firstName: user.displayName?.split(' ').first ?? '',
          lastName: user.displayName?.split(' ').last ?? '',
          username: user.email!.split('@').first,
          email: user.email!,
          state: "",
          city: "",
          barangay: "",
          zip: 0,
          streetName: "",
          uid: user.uid,
        );

        // Show the address dialog
        await showAddressDialog(
            context, user.uid, user.email!.split('@').first, _usersCollection);
      }

      // Retrieve the role from Firestore
      final role = userDoc.exists ? userDoc['role'] : 1; // Default role is 1
      final username = userDoc.exists ? userDoc['username'] : user.email;

      // Save the username in SharedPreferences for session-wide access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setInt('role', role);

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
    } catch (e) {
      print("Error during Google sign-in: $e");
      toastification.show(
        context: context,
        title: Text('Login Failed'),
        description: Text('An error occurred during Google sign-in.'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 4),
      );
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
                                      color: Color(0xFF1877F2)),
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
                                  onPressed: _signInWithGoogle,
                                  icon: Image.asset(
                                    "assets/icons/google.png",
                                    height: 22,
                                  ),
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

Future<void> showAddressDialog(BuildContext context, String userId,
    String initialUsername, CollectionReference usersCollection) async {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController =
      TextEditingController(text: initialUsername);
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController barangayController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController streetNameController = TextEditingController();

  bool isSaving = false; // To track the save operation

  await showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing the dialog without saving
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            titlePadding: const EdgeInsets.all(0),
            actionsAlignment: MainAxisAlignment.center,
            title: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFCA2E55),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text(
                "Complete your details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: Colors.white,
                ),
              ),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Please enter your username and address to complete registration of your account.",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Username Field
                    _buildTextField(
                      "Username",
                      "Your username",
                      true,
                      usernameController,
                      validator: _validateRequiredField,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9_-]')),
                        LengthLimitingTextInputFormatter(50),
                      ],
                    ),
                    // State/Province Field
                    _buildTextField(
                      "State/Province",
                      "Your state/province",
                      true,
                      stateController,
                      validator: _validateRequiredField,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(255),
                      ],
                    ),
                    // City/Municipality Field
                    _buildTextField(
                      "City/Municipality",
                      "Your city/municipality",
                      true,
                      cityController,
                      validator: _validateRequiredField,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(255),
                      ],
                    ),
                    // Barangay Field
                    _buildTextField(
                      "Barangay",
                      "Your barangay",
                      true,
                      barangayController,
                      validator: _validateRequiredField,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(255),
                      ],
                    ),
                    // Street Name Field
                    _buildTextField(
                      "House No/Bldg./Street",
                      "Your house no./bldg./street",
                      true,
                      streetNameController,
                      validator: _validateRequiredField,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(255),
                      ],
                    ),
                    // ZIP Code Field
                    _buildTextField(
                      "ZIP Code",
                      "Your ZIP code",
                      true,
                      zipController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ZIP Code is required';
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return 'Enter a valid ZIP Code (numbers only)';
                        }
                        if (value.length > 4) {
                          return 'ZIP Code must be a maximum of 4 digits';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              GradientButton(
                text: isSaving ? "Saving..." : "Save",
                isEnabled: !isSaving,
                onPressed: isSaving
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isSaving = true;
                          });

                          try {
                            // Log the start of the save operation
                            print("Starting save operation...");

                            // Validate unique username
                            print("Validating unique username...");
                            final usernameError = await _validateUniqueUsername(
                                usernameController.text,
                                usersCollection,
                                initialUsername);
                            if (usernameError != null) {
                              print(
                                  "Username validation failed: $usernameError");
                              // Show error manually
                              toastification.show(
                                context: context,
                                title: Text('Username taken'),
                                description: Text(
                                    'The username ${usernameController.text} is already taken.'),
                                type: ToastificationType.error,
                                autoCloseDuration: const Duration(seconds: 4),
                              );
                              setState(() {
                                isSaving = false;
                              });
                              return;
                            }
                            print("Username validation passed.");

                            // Update the user's main document in the 'users' collection
                            print("Updating main user document...");
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .update({
                              'username': usernameController.text,
                            });
                            print("Main user document updated successfully.");

                            // Add the address to the 'locations' subcollection
                            print(
                                "Adding address to 'locations' subcollection...");
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('locations')
                                .add({
                              'state_province': stateController.text,
                              'city_municipality': cityController.text,
                              'barangay': barangayController.text,
                              'house_no_building_street':
                                  streetNameController.text,
                              'zip': int.tryParse(zipController.text) ?? 0,
                              'main_location': true,
                              'created_at': Timestamp.now(),
                              'modified_at': Timestamp.now(),
                            });
                            print(
                                "Address added to 'locations' subcollection successfully.");

                            Navigator.of(context).pop(); // Close the dialog
                          } catch (e) {
                            print("Error saving details: $e");
                            toastification.show(
                              context: context,
                              title: Text('Error'),
                              description: Text(
                                  'An error occurred while saving your details.'),
                              type: ToastificationType.error,
                              autoCloseDuration: const Duration(seconds: 4),
                            );
                          } finally {
                            setState(() {
                              isSaving = false;
                            });
                            print("Save operation completed.");
                          }
                        } else {
                          print("Form validation failed.");
                        }
                      },
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildTextField(
  String label,
  String hint,
  bool isRequired,
  TextEditingController? controller, {
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
              fontWeight: FontWeight.bold,
            ),
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
        ),
      ],
    ),
  );
}

String? _validateRequiredField(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field is required';
  }
  return null;
}

Future<String?> _validateUniqueUsername(String? value,
    CollectionReference usersCollection, String currentUsername) async {
  if (value == null || value.isEmpty) {
    return 'Username is required';
  }

  // If the username is the same as the current username, skip validation
  if (value == currentUsername) {
    return null; // Username is valid
  }

  // Query Firestore to check if the username exists
  final querySnapshot =
      await usersCollection.where('username', isEqualTo: value).get();

  // Check if the username exists
  if (querySnapshot.docs.isNotEmpty) {
    return 'Username is already taken';
  }

  return null; // Username is unique
}
