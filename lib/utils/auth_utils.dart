import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/pages/catalog_page.dart';
import 'package:itelec_quiz_one/pages/admin/manage_orders.dart';

Future<void> checkIfLoggedIn(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  final prefs = await SharedPreferences.getInstance();
  final role = prefs.getInt('role');
  print('checkIfLoggedIn User: $user');
  print('checkIfLoggedIn Role: $role');

  if (user != null && role != null) {
    print('checkIfLoggedIn User is logged in with role');
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      if (role == 3) {
        print("Navigating to ManageOrdersPage...");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ManageOrdersPage()),
        );
        return;
      } else if (role == 1) {
        print("Navigating to CatalogPage...");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CatalogPage()),
        );
        return;
      }
    }
  }
}

Future<void> registerUserGoogle({
  required String firstName,
  required String lastName,
  required String username,
  required String email,
  required String state,
  required String city,
  required String barangay,
  required int zip,
  required String streetName,
  required String uid,
}) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add user document
  await _firestore.collection('users').doc(uid).set({
    'first_name': firstName,
    'last_name': lastName,
    'username': username,
    'email': email,
    'role': 1,
    'created_at': Timestamp.now(),
    'modified_at': Timestamp.now(),
    'is_deleted': false,
    'favorites': [],
  });

  // Add location as a subcollection
  await _firestore.collection('users').doc(uid).collection('locations').add({
    'state_province': state,
    'city_municipality': city,
    'barangay': barangay,
    'zip': zip,
    'house_no_building_street': streetName,
    'main_location': true,
    'created_at': Timestamp.now(),
    'modified_at': Timestamp.now(),
  });
}
