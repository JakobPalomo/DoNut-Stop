import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:flutter/services.dart';
import 'package:itelec_quiz_one/components/buttons.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/pages/login_page.dart';
import 'package:itelec_quiz_one/pages/registration_page.dart';
import 'package:toastification/toastification.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert'; // For Base64 encoding
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController contactNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
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
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  bool isEditing = false;
  int selectedRole = 1; // Default to 1 (Customer)
  Map<String, dynamic> user = {};

  final List<Map<String, dynamic>> roles = [
    {'value': 1, 'label': 'Customer', 'drawer': UserDrawer()},
    {'value': 2, 'label': 'Employee', 'drawer': EmployeeDrawer()},
    {'value': 3, 'label': 'Admin', 'drawer': AdminDrawer()},
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

  Future<String?> _validateUniqueUsername(String? value) async {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    // Query Firestore to check if the username exists
    final querySnapshot =
        await _usersCollection.where('username', isEqualTo: value).get();

    // Check if the username exists and is not the current user's username
    if (querySnapshot.docs.isNotEmpty &&
        querySnapshot.docs.first.id != user['id']) {
      return 'Username is already taken';
    }

    return null; // Username is unique
  }

  @override
  void initState() {
    super.initState();
    fetchAuthenticatedUserData();
  }

  Future<void> fetchAuthenticatedUserData() async {
    try {
      // Get the authenticated user's UID
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("No authenticated user found.");
      }

      final userId = currentUser.uid;
      print("Authenticated user ID: $userId");

      // Fetch the user's main document
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        throw Exception("User document not found.");
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      // Fetch the locations subcollection
      final locationsSnapshot =
          await _usersCollection.doc(userId).collection('locations').get();
      final locations = locationsSnapshot.docs.map((locationDoc) {
        return {
          ...locationDoc.data(),
          "id": locationDoc.id,
        };
      }).toList();

      // Combine user data with locations and format timestamps
      final formattedUserData = {
        ...userData,
        "id": userId,
        "locations": locations,
        "created_at": userData['created_at'] is Timestamp
            ? DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                .format(userData['created_at'].toDate())
            : "2024-01-10T10:30:00",
        "modified_at": userData['modified_at'] is Timestamp
            ? DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                .format(userData['modified_at'].toDate())
            : "2024-01-10T10:30:00",
      };

      // Store the data in the `user` variable
      setState(() {
        user = formattedUserData;

        // Initialize controllers with user data
        firstNameController.text = user['first_name'] ?? '';
        lastNameController.text = user['last_name'] ?? '';
        usernameController.text = user['username'] ?? '';
        contactNoController.text = user['contact_no']?.toString() ?? '';
        emailController.text = user['email'] ?? '';
        selectedRole = user['role'] ?? 1;

        // Populate location controllers where main_location is true
        if (user['locations'] != null && user['locations'] is List) {
          final mainLocation = (user['locations'] as List)
              .cast<Map<String, dynamic>>()
              .firstWhere(
                (location) => location['main_location'] == true,
                orElse: () => <String, dynamic>{},
              );

          if (mainLocation.isNotEmpty) {
            stateController.text = mainLocation['state_province'] ?? '';
            cityController.text = mainLocation['city_municipality'] ?? '';
            barangayController.text = mainLocation['barangay'] ?? '';
            streetController.text =
                mainLocation['house_no_building_street'] ?? '';
            zipCodeController.text = mainLocation['zip']?.toString() ?? '';
          }
        }
      });

      print("User data fetched successfully: $user");
    } catch (e) {
      print("Error fetching user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch user data."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _promptForPassword() async {
    final controller = TextEditingController();
    bool obscureText = true;

    return showDialog<String>(
      context: context,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Re-enter Password",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: Colors.white,
                  ),
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.fromLTRB(10, 15, 20, 5),
                child: SizedBox(
                  height: 80,
                  child: Column(
                    children: [
                      const Text(
                        "Please enter your password to reauthenticate your account.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: controller,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black26),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color(0xFFCA2E55), width: 2.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                          ),
                        ),
                        cursorColor: const Color(0xFFCA2E55),
                        style: const TextStyle(
                            fontFamily: 'Inter', color: Colors.black),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(255)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                CustomOutlinedButton(
                  text: "Cancel",
                  bgColor: Colors.white,
                  textColor: const Color(0xFFCA2E55),
                  onPressed: () =>
                      Navigator.of(context).pop(null), // Return null on cancel
                ),
                const SizedBox(width: 10),
                GradientButton(
                  text: "Submit",
                  onPressed: () {
                    final password = controller.text.trim();
                    print("Password entered in dialog: $password");
                    Navigator.of(context)
                        .pop(password); // Return the entered password
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _reauthenticateUser(User currentUser, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: password,
      );
      await currentUser.reauthenticateWithCredential(credential);
      print("User reauthenticated successfully.");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception("Incorrect password. Please try again.");
      } else {
        throw Exception("${e.message}");
      }
    } catch (e) {
      throw Exception("Unexpected error during reauthentication.");
    }
  }

  Future<void> updateFirestoreData() async {
    try {
      // Get the current user
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("No authenticated user found.");
      }

      // Check if the email has changed
      if (emailController.text != user['email']) {
        final password = await _promptForPassword();
        print("Password entered: $password");
        if (password == null || password.isEmpty) {
          throw Exception("Password is required for reauthentication.");
        }
        await _reauthenticateUser(currentUser, password);
        await currentUser.updateEmail(emailController.text);
        Future.delayed(Duration.zero, () => passwordController.clear());
        print("Firebase Auth email updated.");
      }

      // Update the user's main document in the 'users' collection
      await _firestore.collection('users').doc(currentUser.uid).update({
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'username': usernameController.text,
        'contact_no': contactNoController.text,
        'email': emailController.text,
        'role': selectedRole, // Update the role
        'modified_at': DateTime.now().toIso8601String(),
        'profile_path': _base64Image ?? user['profile_path'],
      });

      // Update the 'locations' subcollection using the provided location ID
      final mainLocation =
          (user['locations'] as List).cast<Map<String, dynamic>>().firstWhere(
                (location) => location['main_location'] == true,
                orElse: () => <String, dynamic>{},
              );

      if (mainLocation.isNotEmpty && mainLocation['id'] != null) {
        await _firestore
            .collection('users')
            .doc(user['id'])
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
          await _firestore.collection('users').doc(user['id']).get();
      final updatedUserData = updatedUserDoc.data();

      if (updatedUserData != null) {
        // Fetch the updated locations subcollection
        final updatedLocationsSnapshot = await _firestore
            .collection('users')
            .doc(user['id'])
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
          user.clear();
          user.addAll({
            ...updatedUserData,
            'locations': updatedLocations,
          });
          isEditing = false;
        });
      }

      // Show success message
      toastification.show(
        context: context,
        title: Text('User profile updated'),
        description: Text('Your profile has been updated successfully.'),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 4),
      );
    } catch (e) {
      // Reset the controller values to the original user data
      // _resetUserData();

      // Extract the error message
      String errorMessage = e.toString();
      if (errorMessage.contains('] ')) {
        errorMessage = errorMessage.split('] ').last; // Get the part after "] "
      }

      // Show error message
      print("Error updating Firestore data: $e");
      toastification.show(
        context: context,
        title: Text('Error updating profile'),
        description: Text(errorMessage),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 4),
      );
    }
  }

  void _resetUserData() {
    setState(() {
      // Reset text controllers with the original user data
      firstNameController.text = user['first_name'] ?? '';
      lastNameController.text = user['last_name'] ?? '';
      usernameController.text = user['username'] ?? '';
      contactNoController.text = user['contact_no']?.toString() ?? '';
      emailController.text = user['email'] ?? '';
      selectedRole = user['role'] ?? 1;

      // Reset location controllers
      if (user['locations'] != null && user['locations'] is List) {
        final mainLocation =
            (user['locations'] as List).cast<Map<String, dynamic>>().firstWhere(
                  (location) => location['main_location'] == true,
                  orElse: () => <String, dynamic>{},
                );

        if (mainLocation.isNotEmpty) {
          stateController.text = mainLocation['state_province'] ?? '';
          cityController.text = mainLocation['city_municipality'] ?? '';
          barangayController.text = mainLocation['barangay'] ?? '';
          streetController.text =
              mainLocation['house_no_building_street'] ?? '';
          zipCodeController.text = mainLocation['zip']?.toString() ?? '';
        }
      }
    });
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
    return Scaffold(
      backgroundColor: Color(0xFFFFE0B6),
      appBar: isEditing
          ? AppBarWithBackAndTitle(
              title: "Edit Profile",
              onBackPressed: () {
                setState(() {
                  isEditing = false;
                });
              },
            )
          : AppBarWithMenuAndTitle(title: "My Profile"),
      drawer: isEditing
          ? null
          : roles.firstWhere(
              (role) => role['value'] == selectedRole,
              orElse: () => {'drawer': UserDrawer()},
            )['drawer'],
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
                            padding: const EdgeInsets.only(bottom: 10, top: 30),
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
                                        : user['profile_path'] != null &&
                                                user['profile_path']!
                                                    .startsWith('data:image/')
                                            ? Image.memory(
                                                base64Decode(
                                                    user['profile_path']!
                                                        .split(',')
                                                        .last),
                                                width: 180,
                                                height: 180,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                user['profile_path'] ??
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
                                      borderRadius: BorderRadius.circular(100),
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
                      "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}",
                      style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'Inter',
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
                              // _buildPasswordField("Password", "Your password",
                              //     true, passwordController,
                              //     validator: _validatePassword),
                              // _buildPasswordField(
                              //     "Confirm Password",
                              //     "Confirm your password",
                              //     true,
                              //     confirmPasswordController,
                              //     validator: _validateConfirmPassword),
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
                              SizedBox(height: 20),
                              Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 20,
                                  runSpacing: 10,
                                  children: [
                                    CustomOutlinedButton(
                                        text: "Cancel",
                                        bgColor: Colors.white,
                                        textColor: Color(0xFFCA2E55),
                                        onPressed: () {
                                          _resetUserData();
                                          setState(() {
                                            isEditing = false;
                                          });
                                        }),
                                    GradientButton(
                                      text: "Save",
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          final usernameError =
                                              await _validateUniqueUsername(
                                                  usernameController.text);
                                          if (usernameError != null) {
                                            // Show error manually
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(usernameError),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                          // Save the changes to Firestore
                                          await updateFirestoreData();
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
                            _buildProfileDetail(
                                "Username", user['username'] ?? '-'),
                            _buildProfileDetail(
                                "Email Address", user['email'] ?? '-'),
                            _buildProfileDetail(
                                "Contact Number", user['contact_no'] ?? '-'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildProfileDetail(
                                      "State/Province", stateController.text),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: _buildProfileDetail(
                                      "City/Municipality", cityController.text),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: _buildProfileDetail(
                                      "Barangay", barangayController.text),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 20,
                                runSpacing: 10,
                                children: [
                                  CustomOutlinedButton(
                                    text: "Logout",
                                    bgColor: Colors.white,
                                    textColor: Color(0xFFCA2E55),
                                    onPressed: () {
                                      logout(context);
                                    },
                                  ),
                                  GradientButton(
                                    text: "Edit",
                                    onPressed: () {
                                      setState(() {
                                        isEditing = !isEditing;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
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
