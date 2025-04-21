import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itelec_quiz_one/pages/catalog_page.dart';
import 'package:itelec_quiz_one/pages/product_page.dart';
import 'dart:convert';
import 'package:toastification/toastification.dart';

class MyFavoritesPage extends StatefulWidget {
  const MyFavoritesPage({super.key});

  @override
  State<MyFavoritesPage> createState() => _MyFavoritesPageState();
}

class _MyFavoritesPageState extends State<MyFavoritesPage> {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  Map<String, dynamic>? userData;
  bool isLoading = true; // Initially set to true

  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true; // Start loading
      });

      final auth = FirebaseAuth.instance;
      final data =
          await fetchAuthenticatedUserData(auth, _usersCollection, context);
      if (data != null) {
        setState(() {
          userData = data;
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load user data."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  Future<void> toggleFavoriteStatus(String userId, String productId,
      Map<String, dynamic> userData, bool isFav, String name) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      List<dynamic> favorites = userData['favorites'] ?? [];

      if (favorites.contains(productId)) {
        // Remove from favorites
        favorites.remove(productId);
        await userRef.update({'favorites': favorites});
        print("Product removed from favorites.");
        toastification.show(
          context: context,
          title: Text('Product removed from favorites'),
          description: Text('$name has been removed from your favorites.'),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 4),
        );
      } else {
        // Add to favorites
        favorites.add(productId);
        await userRef.update({'favorites': favorites});
        print("Product added to favorites.");
        toastification.show(
          context: context,
          title: Text('Product added to favorites'),
          description: Text('$name has been added to your favorites.'),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 4),
        );
      }

      // Refresh user data
      final updatedUserDoc = await userRef.get();
      final updatedUserData = updatedUserDoc.data() as Map<String, dynamic>;

      setState(() {
        userData['favorites'] = updatedUserData['favorites'];
      });
    } catch (e) {
      print("Error toggling favorite status: $e");
      toastification.show(
        context: context,
        title: Text('Error toggling favorite status'),
        description:
            Text('Failed to update favorite status. Please try again.'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 4),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return MaterialApp(
      title: "My Favorites",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFE0B6),
      ),
      home: Scaffold(
        appBar: AppBarWithMenuAndTitle(title: "My Favorites"),
        drawer: UserDrawer(),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC345E)),
                  backgroundColor: Color(0xFFFF7171),
                  strokeWidth: 5.0,
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 1500),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Add the title at the top
                            Text(
                              "My Favorites",
                              style: TextStyle(
                                fontSize: 30,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF462521),
                              ),
                              softWrap: true,
                            ),
                            SizedBox(height: 20), // Add spacing below the title
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .snapshots(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (!userSnapshot.hasData ||
                                    userSnapshot.data!['favorites'] == null) {
                                  return const Center(
                                    child: Text(
                                      'No favorites yet.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFC7A889),
                                      ),
                                    ),
                                  );
                                }

                                var userFavorites =
                                    userSnapshot.data!['favorites'] ?? [];

                                if (userFavorites.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'No favorite products found.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFC7A889),
                                      ),
                                    ),
                                  );
                                }

                                return StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('products')
                                      .where(FieldPath.documentId,
                                          whereIn: userFavorites)
                                      .snapshots(),
                                  builder: (context, productSnapshot) {
                                    if (productSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    if (!productSnapshot.hasData ||
                                        productSnapshot.data!.docs.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'No favorite products found.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFC7A889),
                                          ),
                                        ),
                                      );
                                    }

                                    final favoriteProducts =
                                        productSnapshot.data!.docs;

                                    return Wrap(
                                      spacing: 5,
                                      runSpacing: 15,
                                      children: favoriteProducts.map((product) {
                                        return SizedBox(
                                          width: 240,
                                          height: 350,
                                          child: SingleChildScrollView(
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(right: 20),
                                              child: MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () {
                                                      print(
                                                          "Navigating to ProductPage with:");
                                                      print(
                                                          "Image: ${product['image']}\nTitle: ${product['name']}\nDescription: ${product['description']}\nNew Price: ₱${product['price'].toStringAsFixed(2)}");
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProductPage(
                                                            productId:
                                                                product.id,
                                                            image: product[
                                                                'image'],
                                                            title:
                                                                product['name'],
                                                            description: product[
                                                                'description'],
                                                            newPrice:
                                                                '₱${product['price'].toStringAsFixed(2)}',
                                                            isFavInitial:
                                                                userFavorites
                                                                    .contains(
                                                                        product
                                                                            .id),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    splashColor: Colors.brown
                                                        .withOpacity(0.2),
                                                    child: Ink(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFFFEEE1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            10,
                                                                            40,
                                                                            10,
                                                                            0),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  child: product['image'] !=
                                                                              null &&
                                                                          product['image']
                                                                              .isNotEmpty &&
                                                                          product['image'].startsWith(
                                                                              'data:image/')
                                                                      ? Image
                                                                          .memory(
                                                                          base64Decode(product['image']
                                                                              .split(',')
                                                                              .last),
                                                                          width:
                                                                              180,
                                                                          height:
                                                                              180,
                                                                          fit: BoxFit
                                                                              .contain,
                                                                        )
                                                                      : Image
                                                                          .asset(
                                                                          product['image'] != null && product['image'].isNotEmpty
                                                                              ? product['image']
                                                                              : 'assets/front_donut/fdonut1.png',
                                                                          width:
                                                                              180,
                                                                          height:
                                                                              180,
                                                                          fit: BoxFit
                                                                              .contain,
                                                                        ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                top: 10,
                                                                left: 0,
                                                                child:
                                                                    IconButton(
                                                                  icon: Icon(
                                                                    Icons
                                                                        .favorite,
                                                                    color: Color(
                                                                        0xFFCA2E55),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    await toggleFavoriteStatus(
                                                                      userData![
                                                                          'id'],
                                                                      product
                                                                          .id,
                                                                      userData as Map<
                                                                          String,
                                                                          dynamic>,
                                                                      userFavorites
                                                                          .contains(
                                                                              product.id),
                                                                      product[
                                                                          'name'],
                                                                    );
                                                                    setState(
                                                                        () {
                                                                      userFavorites =
                                                                          userData!['favorites'] ??
                                                                              [];
                                                                    });
                                                                  },
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5),
                                                                  constraints:
                                                                      BoxConstraints(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(width: 12),
                                                          Container(
                                                            padding: EdgeInsets
                                                                .fromLTRB(20,
                                                                    30, 20, 20),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  product[
                                                                      'name'],
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Inter',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        16,
                                                                    color: Color(
                                                                        0xFF462521),
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                Text(
                                                                  product[
                                                                      'description'],
                                                                  maxLines: 3,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Inter',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize:
                                                                        12,
                                                                    color: Color(
                                                                        0xFF665A49),
                                                                  ),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    SizedBox(
                                                                        width:
                                                                            10),
                                                                    Text(
                                                                      '₱${product['price'].toStringAsFixed(2)}',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Inter',
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                        fontSize:
                                                                            22,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  ],
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
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
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
