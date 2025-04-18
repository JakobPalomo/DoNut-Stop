import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:flutter/services.dart';
import 'package:itelec_quiz_one/components/buttons.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/pages/registration_page.dart';
import 'package:toastification/toastification.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert'; // For Base64 encoding
import 'package:dropdown_button2/dropdown_button2.dart';

class ViewEditUserPage extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic> user;

  const ViewEditUserPage(
      {this.isEditing = false, this.user = const {}, super.key});

  @override
  State<ViewEditUserPage> createState() => _ViewEditUserPageState();
}

class _ViewEditUserPageState extends State<ViewEditUserPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController contactNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController barangayController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _selectedImage; // For mobile
  Uint8List? _webImage; // For web
  String? _base64Image; // For Base64 encoding
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late bool isEditing;
  int selectedRole = 1;

  final List<Map<String, dynamic>> roleOptions = [
    {'value': 1, 'label': 'Customer'},
    {'value': 2, 'label': 'Employee'},
    {'value': 3, 'label': 'Admin'},
  ];

  String? _validateRequiredField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _validateContactNo(String? value) {
    if (value != null && value != '') {
      if (value.length != 11) {
        return 'Contact number must be 11 digits long';
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
        return 'Contact number must contain only digits';
      }
      if (value[0] != '0') {
        return 'Contact number must start with 0';
      }
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

  @override
  void initState() {
    super.initState();
    print("User data: ${widget.user}");
    isEditing = widget.isEditing;

    // Initialize controllers with user data
    firstNameController.text = widget.user['first_name'] ?? '';
    lastNameController.text = widget.user['last_name'] ?? '';
    usernameController.text = widget.user['username'] ?? '';
    contactNoController.text = widget.user['contact_no']?.toString() ?? '';
    emailController.text = widget.user['email'] ?? '';
    selectedRole = widget.user['role'] ?? 1; // Default to 0 (Customer)

    // Populate location controllers where main_location is true
    if (widget.user['locations'] != null && widget.user['locations'] is List) {
      final mainLocation = (widget.user['locations'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere(
            (location) => location['main_location'] == true,
            orElse: () => <String, dynamic>{},
          );

      if (mainLocation.isNotEmpty) {
        stateController.text = mainLocation['state_province'] ?? '';
        cityController.text = mainLocation['city_municipality'] ?? '';
        barangayController.text = mainLocation['barangay'] ?? '';
        streetController.text = mainLocation['house_no_building_street'] ?? '';
        zipCodeController.text = mainLocation['zip']?.toString() ?? '';
      }
    }
  }

  Future<void> updateFirestoreData() async {
    try {
      // Update the user's main document in the 'users' collection
      await _firestore.collection('users').doc(widget.user['id']).update({
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'username': usernameController.text,
        'contact_no': contactNoController.text,
        'email': emailController.text,
        'role': selectedRole, // Update the role
        'modified_at': DateTime.now().toIso8601String(),
        'profile_path': _base64Image ?? widget.user['profile_path'],
      });

      // Update the 'locations' subcollection using the provided location ID
      final mainLocation = (widget.user['locations'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere(
            (location) => location['main_location'] == true,
            orElse: () => <String, dynamic>{},
          );

      if (mainLocation.isNotEmpty && mainLocation['id'] != null) {
        await _firestore
            .collection('users')
            .doc(widget.user['id'])
            .collection('locations')
            .doc(mainLocation['id'])
            .update({
          'state_province': stateController.text,
          'city_municipality': cityController.text,
          'barangay': barangayController.text,
          'house_no_building_street': streetController.text,
          'zip': int.tryParse(zipCodeController.text) ?? 0,
          'modified_at': Timestamp.now(),
        });
      }

      // Fetch the updated user data
      final updatedUserDoc =
          await _firestore.collection('users').doc(widget.user['id']).get();
      final updatedUserData = updatedUserDoc.data();

      if (updatedUserData != null) {
        // Fetch the updated locations subcollection
        final updatedLocationsSnapshot = await _firestore
            .collection('users')
            .doc(widget.user['id'])
            .collection('locations')
            .get();

        final updatedLocations = updatedLocationsSnapshot.docs.map((doc) {
          return {
            ...doc.data(),
            'id': doc.id,
          };
        }).toList();

        // Update the user data in the state
        setState(() {
          widget.user.clear();
          widget.user.addAll({
            ...updatedUserData,
            'locations': updatedLocations,
          });
          isEditing = false;
        });
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User data updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle errors
      print("Error updating Firestore data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update user data."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProfileDetail(String label, String value) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF462521),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
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
    return Expanded(
      child: Padding(
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
      ),
    );
  }

  Widget _buildPasswordField(String label, String hint, bool isRequired,
      TextEditingController passwordController,
      {String? Function(String?)? validator}) {
    return Expanded(
      child: PasswordField(
          label: label,
          hint: hint,
          isRequired: isRequired,
          validator: validator),
    );
  }

  double degreesToRadians(double degrees) {
    return degrees * (3.1415926535897932 / 180);
  }

  Widget _buildDropdown({
    required String label,
    required int value,
    required List<Map<String, dynamic>> options,
    required Function(int?) onChanged,
    bool isRequired = false,
  }) {
    return Column(
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
        DropdownButton2<int>(
          value: value,
          isExpanded: false,
          items: options.map((option) {
            return DropdownMenuItem<int>(
              value: option['value'] as int,
              child: Text(option['label'] as String),
            );
          }).toList(),
          onChanged: onChanged,
          underline: const SizedBox(),
          buttonStyleData: ButtonStyleData(
            height: 47,
            width: 240,
            padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Color(0xFF303030)),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            width: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(0),
          ),
          menuItemStyleData: MenuItemStyleData(
            height: 40,
            padding: const EdgeInsets.only(left: 10),
          ),
          iconStyleData: IconStyleData(
            icon: Transform.rotate(
              angle: degreesToRadians(90),
              child: const Icon(Icons.chevron_right),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "${isEditing ? "Edit" : "View"} User",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFE0B6),
        fontFamily: 'Inter',
      ),
      home: Scaffold(
        backgroundColor: Color(0xFFFFE0B6),
        appBar: AppBarWithBackAndTitle(
          title: "${isEditing ? "Edit" : "View"} User",
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: CustomScrollView(
          slivers: [
            // Profile Image Section
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Stack(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10, top: 30),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[700],
                                  border: Border.all(
                                    color: Color(0xFFCA2E55),
                                    width: 5,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: _webImage != null
                                      ? Image.memory(
                                          _webImage!,
                                          width: 180,
                                          height: 180,
                                          fit: BoxFit.cover,
                                        )
                                      : _selectedImage != null
                                          ? Image.file(
                                              _selectedImage!,
                                              width: 180,
                                              height: 180,
                                              fit: BoxFit.cover,
                                            )
                                          : widget.user['profile_path'] !=
                                                      null &&
                                                  widget.user['profile_path']!
                                                      .startsWith('data:image/')
                                              ? Image.memory(
                                                  base64Decode(widget
                                                      .user['profile_path']!
                                                      .split(',')
                                                      .last),
                                                  width: 180,
                                                  height: 180,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.asset(
                                                  widget.user['profile_path'] ??
                                                      'transparent_pic.png',
                                                  width: 180,
                                                  height: 180,
                                                  fit: BoxFit.cover,
                                                ),
                                ),
                              ),
                            ),
                            // Floating Action Button for Upload Image
                            if (isEditing)
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: Material(
                                  color: Colors.transparent,
                                  shape: CircleBorder(),
                                  child: InkWell(
                                    splashColor: Colors.white.withOpacity(0.5),
                                    onTap: () async {
                                      final ImagePicker picker = ImagePicker();
                                      final XFile? pickedFile =
                                          await picker.pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 70, // Compress the image
                                      );

                                      if (pickedFile != null) {
                                        if (kIsWeb) {
                                          // For web, read the image as bytes
                                          final Uint8List webImage =
                                              await pickedFile.readAsBytes();
                                          final int imageSize =
                                              webImage.lengthInBytes;

                                          if (imageSize > 300 * 1024) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Image size exceeds 300KB",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                            return;
                                          }

                                          // Add the appropriate prefix for Base64
                                          final String base64Image =
                                              "data:image/${pickedFile.name.split('.').last};base64," +
                                                  base64Encode(webImage);

                                          setState(() {
                                            _webImage = webImage;
                                            _selectedImage =
                                                null; // Clear mobile image
                                            _base64Image =
                                                base64Image; // Store Base64 string with prefix
                                          });
                                          print(
                                              "Web image selected and encoded to Base64");
                                        } else {
                                          // For mobile, read the image file
                                          final File imageFile =
                                              File(pickedFile.path);
                                          final int imageSize =
                                              await imageFile.length();

                                          if (imageSize > 300 * 1024) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Image size exceeds 300KB",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                            return;
                                          }

                                          final Uint8List imageBytes =
                                              await imageFile.readAsBytes();
                                          // Add the appropriate prefix for Base64
                                          final String base64Image =
                                              "data:image/${pickedFile.name.split('.').last};base64," +
                                                  base64Encode(imageBytes);

                                          setState(() {
                                            _selectedImage = imageFile;
                                            _webImage = null; // Clear web image
                                            _base64Image =
                                                base64Image; // Store Base64 string with prefix
                                          });
                                          print(
                                              "Mobile image selected and encoded to Base64");
                                        }
                                      } else {
                                        print("No image selected.");
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(100),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFCA2E55),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: Text(
                        "${widget.user['first_name'] ?? ''} ${widget.user['last_name'] ?? 'Asherbigge Biggieboo'}",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF462521),
                        )),
                  ),
                ],
              ),
            ),

            // Profile Details Section
            SliverFillRemaining(
              hasScrollBody: false,
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
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 800),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    child: isEditing
                        ? Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  _buildTextField(
                                    "First name",
                                    "Your first name",
                                    true,
                                    firstNameController,
                                    validator: _validateRequiredField,
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(100),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  _buildTextField(
                                    "Last name",
                                    "Your last name",
                                    true,
                                    lastNameController,
                                    validator: _validateRequiredField,
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(100),
                                    ],
                                  ),
                                ]),
                                _buildTextField(
                                  "Username",
                                  "Your username",
                                  true,
                                  usernameController,
                                  validator: _validateRequiredField,
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9_-]')),
                                    LengthLimitingTextInputFormatter(50),
                                  ],
                                ),
                                _buildTextField(
                                  "Email address",
                                  "Your email address",
                                  true,
                                  emailController,
                                  validator: _validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(255),
                                  ],
                                ),
                                Row(children: [
                                  _buildTextField(
                                    "Contact Number",
                                    "Your contact number",
                                    true,
                                    contactNoController,
                                    validator: _validateContactNo,
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                      LengthLimitingTextInputFormatter(11),
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                  _buildDropdown(
                                    label: "Role",
                                    value: selectedRole,
                                    options: roleOptions,
                                    isRequired: true,
                                    onChanged: (newVal) {
                                      if (newVal != null) {
                                        setState(() {
                                          selectedRole = newVal;
                                        });
                                      }
                                    },
                                  ),
                                ]),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
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
                                    ),
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
                                          LengthLimitingTextInputFormatter(255),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildTextField(
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
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2, // Street name field is longer
                                      child: _buildTextField(
                                        "House No/Bldg./Street",
                                        "Your house no./bldg./street",
                                        true,
                                        streetController,
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
                                        zipCodeController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'ZIP Code is required';
                                          }
                                          if (!RegExp(r'^\d+$')
                                              .hasMatch(value)) {
                                            return 'Enter a valid ZIP Code (numbers only)';
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 20,
                                    runSpacing: 10,
                                    children: [
                                      CustomOutlinedButton(
                                          text: "Cancel",
                                          bgColor: Colors.white,
                                          textColor: Color(0xFFCA2E55),
                                          onPressed: () {
                                            // Toggle view/edit mode
                                            if (widget.isEditing) {
                                              Navigator.pop(context);
                                            } else {
                                              setState(() {
                                                isEditing = false;
                                              });
                                            }
                                          }),
                                      GradientButton(
                                        text: "Save",
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            // Save the changes to Firestore
                                            await updateFirestoreData();
                                            if (widget.isEditing) {
                                              Navigator.pop(context);
                                            } else {
                                              // Toggle view/edit mode
                                              setState(() {
                                                isEditing = false;
                                              });
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: _buildProfileDetail("Username",
                                            widget.user['username'] ?? '-')),
                                    Expanded(
                                        child: _buildProfileDetail(
                                            "Email Address",
                                            widget.user['email'] ?? '-')),
                                  ]),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: _buildProfileDetail(
                                            "Contact Number",
                                            widget.user['contact_no'] ?? '-')),
                                    Expanded(
                                        child: _buildProfileDetail(
                                            "Role",
                                            roleOptions.firstWhere(
                                                  (option) =>
                                                      option['value'] ==
                                                      selectedRole,
                                                  orElse: () =>
                                                      {'label': 'Unknown'},
                                                )['label'] ??
                                                'Customer')),
                                  ]),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: _buildProfileDetail(
                                        "State/Province", stateController.text),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: _buildProfileDetail(
                                        "City/Municipality",
                                        cityController.text),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: _buildProfileDetail(
                                        "Barangay", barangayController.text),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: _buildProfileDetail(
                                        "House No.,Bldg./Street",
                                        streetController.text),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: _buildProfileDetail(
                                        "ZIP", zipCodeController.text),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              CustomOutlinedButton(
                                text: "Edit",
                                bgColor: Colors.white,
                                textColor: Color(0xFFCA2E55),
                                onPressed: () {
                                  setState(() {
                                    isEditing = !isEditing;
                                  });
                                },
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
