import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/components/buttons.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:itelec_quiz_one/pages/admin/manage_products.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert'; // For Base64 encoding

class AddEditProductPage extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic> product;

  const AddEditProductPage({
    this.isEditing = false,
    this.product = const {},
    super.key,
  });

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _selectedImage; // For mobile
  Uint8List? _webImage; // For web
  String? _base64Image; // For Base64 encoding
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  @override
  void initState() {
    super.initState();

    // Prefill the text controllers if editing
    if (widget.isEditing) {
      nameController.text = widget.product['name'] ?? '';
      priceController.text = widget.product['price']?.toString() ?? '';
      descriptionController.text = widget.product['description'] ?? '';
    }
  }

  void _createProduct() async {
    if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
      await _productsCollection.add({
        'name': nameController.text,
        'price': double.tryParse(priceController.text) ?? 0.0,
        'description': descriptionController.text,
        'image': _base64Image ?? '',
        'created_at': Timestamp.now(),
        'created_by': _auth.currentUser?.uid,
        'modified_at': Timestamp.now(),
        'modified_by': _auth.currentUser?.uid,
      });
      _resetFormAndNavigate();
    }
  }

  void _updateProduct(
      String id, String newName, double newPrice, String description) async {
    await _productsCollection.doc(id).update({
      'name': newName,
      'price': newPrice,
      'description': description,
      'image': _base64Image ?? widget.product['image'] ?? '',
      'modified_at': Timestamp.now(),
      'modified_by': _auth.currentUser?.uid,
    });
    _resetFormAndNavigate();
  }

  void _resetFormAndNavigate() {
    nameController.clear();
    priceController.clear();
    descriptionController.clear();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManageProductsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE0B6),
      appBar: AppBarWithBackAndTitle(
        title: "${widget.isEditing ? "Edit" : "Add"} a Product",
        onBackPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageProductsPage(),
            ),
          );
        },
      ),
      body: Column(
        children: [
          // Donut Image Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                if (_webImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.memory(
                        _webImage!,
                        width: double.infinity,
                        height: 260,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 260,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else if (widget.isEditing)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: widget.product['image'] != null &&
                              widget.product['image']!.isNotEmpty &&
                              widget.product['image']!.startsWith('data:image/')
                          ? Image.memory(
                              base64Decode(
                                  widget.product['image']!.split(',').last),
                              width: double.infinity,
                              height: 260,
                              fit: BoxFit.contain,
                            )
                          : Image.asset(
                              widget.product['image'] != null &&
                                      widget.product['image']!.isNotEmpty
                                  ? widget.product['image']!
                                  : 'assets/front_donut/fdonut1.png',
                              width: double.infinity,
                              height: 260,
                              fit: BoxFit.contain,
                            ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/icons/no_image.png',
                            width: double.infinity,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Add an image of the product",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFC7A889),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Floating Action Button for Upload Image
                Positioned(
                  bottom: 20,
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    shape: CircleBorder(),
                    child: InkWell(
                      splashColor: Colors.white.withOpacity(0.5),
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 70, // Compress the image
                        );

                        if (pickedFile != null) {
                          if (kIsWeb) {
                            // For web, read the image as bytes
                            final Uint8List webImage =
                                await pickedFile.readAsBytes();
                            final int imageSize = webImage.lengthInBytes;

                            if (imageSize > 300 * 1024) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Image size exceeds 300KB",
                                    style: TextStyle(color: Colors.white),
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
                              _selectedImage = null; // Clear mobile image
                              _base64Image =
                                  base64Image; // Store Base64 string with prefix
                            });
                            print("Web image selected and encoded to Base64");
                          } else {
                            // For mobile, read the image file
                            final File imageFile = File(pickedFile.path);
                            final int imageSize = await imageFile.length();

                            if (imageSize > 300 * 1024) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Image size exceeds 300KB",
                                    style: TextStyle(color: Colors.white),
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
                          widget.isEditing ? Icons.edit : Icons.add,
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

          // Product Details Section
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
                child: Container(
                  constraints: BoxConstraints(maxWidth: 800),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildForm(),
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

  String? _validateRequiredField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
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
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              "Product Name",
              "Enter product name",
              true,
              nameController,
              validator: _validateRequiredField,
            ),
            _buildTextField(
              "Price",
              "Enter price",
              true,
              priceController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Price is required';
                }
                if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
                  return 'Enter a valid price (e.g., 10.00)';
                }
                return null;
              },
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{0,2})?$')),
              ],
            ),
            _buildTextField(
              "Description",
              "Enter description",
              true,
              descriptionController,
              validator: _validateRequiredField,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: [
                CustomOutlinedButton(
                  text: "Cancel",
                  bgColor: Colors.white,
                  textColor: Color(0xFFCA2E55),
                  onPressed: _resetFormAndNavigate,
                ),
                GradientButton(
                  text: widget.isEditing ? "Save" : "Add",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (widget.isEditing) {
                        _updateProduct(
                          widget.product['id'],
                          nameController.text,
                          double.parse(priceController.text),
                          descriptionController.text,
                        );
                      } else {
                        _createProduct();
                      }
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
