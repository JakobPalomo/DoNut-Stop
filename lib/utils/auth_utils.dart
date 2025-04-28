import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/pages/catalog_page.dart';
import 'package:itelec_quiz_one/pages/admin/manage_orders.dart';

Future<void> checkIfLoggedIn(BuildContext context) async {
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
