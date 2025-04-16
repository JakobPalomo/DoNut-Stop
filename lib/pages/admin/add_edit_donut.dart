import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';

class AddEditDonutPage extends StatefulWidget {
  final bool isEditing;

  const AddEditDonutPage({
    this.isEditing = false,
    super.key,
  });

  @override
  State<AddEditDonutPage> createState() => _AddEditDonutPageState();
}

class _AddEditDonutPageState extends State<AddEditDonutPage> {
  final TextEditingController donutNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "${widget.isEditing ? "Edit" : "Add"} Donut",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFE0B6),
        fontFamily: 'Inter',
      ),
      home: Scaffold(
        backgroundColor: Color(0xFFFFE0B6),
        appBar: AppBarWithBackAndTitle(
            title: "${widget.isEditing ? "Edit" : "Add"} Donut"),
        body: Column(
          children: [
            // Donut Image Section
            Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Stack(children: [
                  widget.isEditing
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/front_donut/fdonut1.png',
                            width: 250,
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Column(
                          children: [
                            Text(
                              "Add an image of the product",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFC7A889),
                              ),
                            ),
                            SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/icons/no_image.png',
                                width: 150,
                                height: 150,
                                fit: BoxFit.contain,
                              ),
                            )
                          ],
                        ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFFCA2E55),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        widget.isEditing ? Icons.add : Icons.edit,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  )
                ])),
            SizedBox(height: 20),

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
                  // Ensure maxWidth applies correctly
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
                "Donut Name", "Enter donut name", true, donutNameController,
                validator: _validateRequiredField),
            _buildTextField(
              "Price",
              "Enter price",
              true,
              priceController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Price is required';
                }
                if (!RegExp(r'^\d+$').hasMatch(value)) {
                  return 'Enter a valid price (numbers only)';
                }
                return null;
              },
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            _buildTextField(
                "Description", "Enter description", true, descriptionController,
                validator: _validateRequiredField),
          ],
        ),
      ),
    );
  }
}
