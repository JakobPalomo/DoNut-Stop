import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:donut_stop/pages/login_page.dart';
import '../models/userInformation.dart';
import '../main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donut_stop/components/user_drawers.dart';
import 'package:toastification/toastification.dart';

void main() {
  runApp(const RegistrationPage());
}

final TextEditingController firstNameController = TextEditingController();
final TextEditingController lastNameController = TextEditingController();
final TextEditingController usernameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController stateController = TextEditingController();
final TextEditingController cityController = TextEditingController();
final TextEditingController zipController = TextEditingController();
final TextEditingController confirmPasswordController = TextEditingController();
final TextEditingController streetNameController = TextEditingController();
final TextEditingController barangayController =
    TextEditingController(); // Define a separate controller for Barangay
final _formKey = GlobalKey<FormState>();

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

String? _validateRequiredField(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field is required';
  }
  return null;
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
  if (value.length < 8) {
    return 'Password must be at least 8 characters long';
  }
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Password must contain at least 1 capital letter';
  }
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'Password must contain at least 1 number';
  }
  return null;
}

String? _validateConfirmPassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Confirm Password is required';
  }
  if (value != passwordController.text) {
    return 'Passwords do not match';
  }
  return null;
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  List<UserInformation> submittedData = [];
  int? _editingIndex;
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<String?> _validateUniqueUsername(String? value) async {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    // Query Firestore to check if the username exists
    final querySnapshot =
        await _usersCollection.where('username', isEqualTo: value).get();

    // Check if the username exists and is not the current user's username
    if (querySnapshot.docs.isNotEmpty) {
      return 'Username is already taken';
    }

    return null; // Username is unique
  }

  void _clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    stateController.clear();
    cityController.clear();
    zipController.clear();
    streetNameController.clear();
    barangayController.clear();
  }

  void _deleteEntry(int index) {
    setState(() {
      submittedData.removeAt(index);
    });
  }

  void _editEntry(int index) {
    setState(() {
      _editingIndex = index;
      final user = submittedData[index];
      firstNameController.text = user.firstName;
      lastNameController.text = user.lastName;
      usernameController.text = user.username;
      emailController.text = user.email;
      passwordController.text = user.password;
      confirmPasswordController.text = user.password;
      stateController.text = user.district;
      cityController.text = user.city;
      zipController.text = user.zip;
    });
  }

  void _saveEdit(int index) {
    if (_formKey.currentState!.validate()) {
      setState(() {
        submittedData[index] = UserInformation(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          username: usernameController.text,
          email: emailController.text,
          password: passwordController.text,
          district: stateController.text,
          city: cityController.text,
          zip: zipController.text,
        );
        _editingIndex = null;
        _clearForm();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Update successful!'),
        backgroundColor: Colors.green,
      ));
    }
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final usernameError =
            await _validateUniqueUsername(usernameController.text);
        if (usernameError != null) {
          // Show error manually
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(usernameError),
                backgroundColor: Colors.red,
              ),
            );
          });
          return;
        }

        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Add user document
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
          'username': usernameController.text,
          'email': emailController.text,
          'role': 1,
          'created_at': Timestamp.now(),
          'modified_at': Timestamp.now(),
          'is_deleted': false,
          'favorites': [],
        });

        // Add location as a subcollection
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .collection('locations')
            .add({
          'state_province': stateController.text,
          'city_municipality': cityController.text,
          'barangay': barangayController.text,
          'zip': int.tryParse(zipController.text) ?? 0,
          'house_no_building_street': streetNameController.text,
          'main_location': true,
          'created_at': Timestamp.now(),
          'modified_at': Timestamp.now(),
        });

        toastification.show(
          context: context,
          title: Text('Registration Successful'),
          description: Text('You can now log in.'),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 4),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (e) {
        // Extract the error message
        String errorMessage = e.toString();
        if (errorMessage.contains('] ')) {
          errorMessage =
              errorMessage.split('] ').last; // Get the part after "] "
        }

        // Show the error message in a SnackBar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    }
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

  Widget _buildPasswordField(String label, String hint, bool isRequired,
      TextEditingController passwordController,
      {String? Function(String?)? validator}) {
    return PasswordField(
        label: label, hint: hint, isRequired: isRequired, validator: validator);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithMenuAndTitle(title: "Registration"),
      backgroundColor: const Color(0xFFFFE0B6),
      drawer: GuestDrawer(),
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
                    "Let's sign up!",
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF462521),
                    ),
                  ),
                  if (_editingIndex == null) RegPageTxtFieldSection(),
                  RegPageBtnFieldSection(onRegisterUser: _registerUser),
                  _buildSubmittedDataList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmittedDataList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: submittedData.length,
      itemBuilder: (context, index) {
        final user = submittedData[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: _editingIndex == index
              ? _buildEditForm(index)
              : ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    '${user.firstName} ${user.lastName}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF462521),
                    ),
                  ),
                  subtitle: Text(
                    'Username: ${user.username}\nEmail: ${user.email}\nCity: ${user.city}\nZIP: ${user.zip}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF462521),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editEntry(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteEntry(index),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildEditForm(int index) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
                "First name", "Your first name", true, firstNameController,
                validator: _validateRequiredField),
            _buildTextField(
                "Last name", "Your last name", true, lastNameController,
                validator: _validateRequiredField),
            _buildTextField(
                "Username", "Your username", true, usernameController,
                validator: _validateRequiredField),
            _buildTextField(
                "Email address", "Your email address", true, emailController,
                validator: _validateEmail),
            _buildPasswordField(
                "Password", "Your password", true, passwordController,
                validator: _validatePassword),
            _buildPasswordField("Confirm Password", "Confirm your password",
                true, confirmPasswordController,
                validator: _validateConfirmPassword),
            _buildTextField(
                "State/Province", "Your state/province", true, stateController,
                validator: _validateRequiredField),
            _buildTextField("City/Municipality", "Your city/municipality", true,
                cityController,
                validator: _validateRequiredField),
            _buildTextField("Barangay", "Your barangay", true,
                barangayController, // Use the new Barangay controller
                validator: _validateRequiredField),
            Row(
              children: [
                Expanded(
                  flex: 2, // Street name field is longer
                  child: _buildTextField(
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
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 1, // ZIP code field is shorter
                  child: _buildTextField(
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
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _saveEdit(index),
                  child: Text('Save'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _editingIndex = null;
                      _clearForm();
                    });
                  },
                  child: Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
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
                            child: _buildTextField("First name",
                                "Your first name", true, firstNameController,
                                validator: _validateRequiredField,
                                keyboardType: TextInputType.text,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100)
                                ]),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField("Last name",
                                "Your last name", true, lastNameController,
                                validator: _validateRequiredField,
                                keyboardType: TextInputType.text,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100)
                                ]),
                          ),
                        ],
                      );
                    } else {
                      // Small screen: Use Column to stack fields
                      return Column(
                        children: [
                          _buildTextField("First name", "Your first name", true,
                              firstNameController,
                              validator: _validateRequiredField,
                              keyboardType: TextInputType.text,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100)
                              ]),
                          _buildTextField("Last name", "Your last name", true,
                              lastNameController,
                              validator: _validateRequiredField,
                              keyboardType: TextInputType.text,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100)
                              ]),
                        ],
                      );
                    }
                  },
                ),
              ),
              _buildTextField(
                "Username",
                "Your username",
                true,
                usernameController,
                validator: _validateRequiredField,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_-]')),
                  LengthLimitingTextInputFormatter(50)
                ],
              ),
              _buildTextField(
                  "Email address", "Your email address", true, emailController,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [LengthLimitingTextInputFormatter(255)]),
              _buildPasswordField(
                  "Password", "Your password", true, passwordController,
                  validator: _validatePassword),
              _buildPasswordField("Confirm Password", "Confirm your password",
                  true, confirmPasswordController,
                  validator: _validateConfirmPassword),
              Container(
                width: double.infinity,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 400) {
                      // Large screen: Use Row for two fields side by side
                      return Row(
                        children: [
                          Expanded(
                              child: _buildTextField("State/Province",
                                  "Your state/province", true, stateController,
                                  validator: _validateRequiredField,
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                LengthLimitingTextInputFormatter(255)
                              ])),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _buildTextField(
                                  "City/Municipality",
                                  "Your city/municipality",
                                  true,
                                  cityController,
                                  validator: _validateRequiredField,
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                LengthLimitingTextInputFormatter(255)
                              ])),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _buildTextField(
                            "Barangay",
                            "Your barangay",
                            true,
                            barangayController, // Use the new Barangay controller
                            validator: _validateRequiredField,
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(255)
                            ],
                          )),
                        ],
                      );
                    } else {
                      // Small screen: Use Column to stack fields
                      return Column(
                        children: [
                          _buildTextField("State/Province",
                              "Your state/province", true, stateController,
                              validator: _validateRequiredField,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(255)
                              ]),
                          _buildTextField("City/Municipality",
                              "Your city/municiplaity", true, cityController,
                              validator: _validateRequiredField,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(255)
                              ]),
                          _buildTextField("Barangay", "Your barangay", true,
                              barangayController, // Use the new Barangay controller
                              validator: _validateRequiredField,
                              keyboardType: TextInputType.text,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(255)
                              ])
                        ],
                      );
                    }
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2, // Street name field is longer
                    child: _buildTextField(
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
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 1, // ZIP code field is shorter
                    child: _buildTextField(
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
                  ),
                ],
              )
            ],
          ),
        ));
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

  Widget _buildPasswordField(String label, String hint, bool isRequired,
      TextEditingController passwordController,
      {String? Function(String?)? validator}) {
    return PasswordField(
        label: label, hint: hint, isRequired: isRequired, validator: validator);
  }
}

class RegPageBtnFieldSection extends StatelessWidget {
  final VoidCallback onRegisterUser;

  const RegPageBtnFieldSection({
    Key? key,
    required this.onRegisterUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 10,
                children: [
                  _buildCancelButton(
                    "Cancel",
                    Colors.white,
                    const Color(0xFFDC345E),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp()),
                      );
                    },
                  ),
                  _buildSignUpButton(
                    "Sign Up",
                    const Color(0xFFDC345E),
                    Colors.white,
                    onRegisterUser,
                  ),
                ].reversed.toList(),
              ),
            ),
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
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(
    String text,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
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
    String text,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
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
                        text: ' *',
                        style: TextStyle(color: Color(0xFFEC2023)),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.label == "Password"
                ? passwordController
                : confirmPasswordController, // Use appropriate controller
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
            validator: widget.validator,
            inputFormatters: [LengthLimitingTextInputFormatter(255)],
          ),
        ],
      ),
    );
  }
}
