import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/components/buttons.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itelec_quiz_one/pages/catalog_page.dart';
import 'package:itelec_quiz_one/pages/product_page.dart';
import 'dart:convert';
import 'package:toastification/toastification.dart';

class AllDonutsPage extends StatefulWidget {
  const AllDonutsPage({super.key});

  @override
  State<AllDonutsPage> createState() => _AllDonutsPageState();
}

class _AllDonutsPageState extends State<AllDonutsPage> {
  final ScrollController _scrollController = ScrollController();
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  Map<String, dynamic>? userData;
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true;
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
        isLoading = false;
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
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return MaterialApp(
      title: "Donuts",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFE0B6),
      ),
      home: Scaffold(
        appBar: AppBarWithSearchAndCart(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              print("Search query: $value");
              _searchQuery = value.trim().toLowerCase();
            });
          },
          onSubmitted: (value) {
            setState(() {
              print("Search submitted: $value");
              _searchQuery = value.trim().toLowerCase();
            });
          },
        ),
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
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 1330),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Container(
                                width: double.infinity,
                                child: Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    direction: Axis.horizontal,
                                    spacing: 20,
                                    runSpacing: 5,
                                    children: [
                                      Text(
                                        "Donuts",
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF462521),
                                        ),
                                        softWrap: true,
                                      ),
                                      // Back Home
                                      Material(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        child: InkWell(
                                          onTap: () {
                                            debugPrint("Back Home clicked");
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CatalogPage(),
                                              ),
                                            );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          splashColor:
                                              Colors.white.withOpacity(0.3),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            child: Text(
                                              "Back Home",
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFFCA2E55),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ])),
                            SizedBox(height: 20),
                            // Donuts List
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .snapshots(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFFDC345E)),
                                      backgroundColor: Color(0xFFFF7171),
                                      strokeWidth: 5.0,
                                    ),
                                  );
                                }
                                var userFavorites =
                                    userSnapshot.data!['favorites'] ?? [];

                                return StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('products')
                                      .snapshots(),
                                  builder: (context, productSnapshot) {
                                    if (productSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Color(0xFFDC345E)),
                                          backgroundColor: Color(0xFFFF7171),
                                          strokeWidth: 5.0,
                                        ),
                                      );
                                    }

                                    if (!productSnapshot.hasData ||
                                        productSnapshot.data!.docs.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'No products found.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFC7A889),
                                          ),
                                        ),
                                      );
                                    }

                                    // Filter products based on the search query
                                    final products =
                                        productSnapshot.data!.docs.where((doc) {
                                      final name =
                                          doc['name'].toString().toLowerCase();
                                      final description = doc['description']
                                          .toString()
                                          .toLowerCase();
                                      final price =
                                          doc['price'].toString().toLowerCase();
                                      return name.contains(_searchQuery) ||
                                          description.contains(_searchQuery) ||
                                          price.contains(_searchQuery);
                                    }).toList();

                                    return Wrap(
                                      spacing: 20,
                                      runSpacing: 20,
                                      children: products.map((product) {
                                        return SizedBox(
                                          width: 240,
                                          height: 360,
                                          child: SingleChildScrollView(
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
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
                                                          productId: product.id,
                                                          image:
                                                              product['image'],
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
                                                      BorderRadius.circular(16),
                                                  splashColor: Colors.brown
                                                      .withOpacity(0.2),
                                                  child: Ink(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFFFEEE1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
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
                                                              child: ClipRRect(
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
                                                                        product['image'] != null &&
                                                                                product['image'].isNotEmpty
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
                                                              child: IconButton(
                                                                icon: Icon(
                                                                  userFavorites.contains(
                                                                          product
                                                                              .id)
                                                                      ? Icons
                                                                          .favorite
                                                                      : Icons
                                                                          .favorite_border,
                                                                  color: Color(
                                                                      0xFFCA2E55),
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  await toggleFavoriteStatus(
                                                                    userData![
                                                                        'id'],
                                                                    product.id,
                                                                    userData as Map<
                                                                        String,
                                                                        dynamic>,
                                                                    userFavorites
                                                                        .contains(
                                                                            product.id),
                                                                    product[
                                                                        'name'],
                                                                  );
                                                                  setState(() {
                                                                    userFavorites =
                                                                        userData!['favorites'] ??
                                                                            [];
                                                                  });
                                                                },
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                constraints:
                                                                    BoxConstraints(),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(width: 12),
                                                        Container(
                                                          padding: EdgeInsets
                                                              .fromLTRB(20, 30,
                                                                  20, 10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                product['name'],
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 16,
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
                                                                maxLines: 2,
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
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                      0xFF665A49),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 10),
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
                                                                          FontWeight
                                                                              .w700,
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
                                        );
                                      }).toList(),
                                    );
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 20),
                            // Buttons
                            Padding(
                              padding: EdgeInsets.fromLTRB(35, 0, 35, 0),
                              child: Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 20,
                                  runSpacing: 10,
                                  children: [
                                    // Back to Top Button
                                    CustomOutlinedButton(
                                      text: "Back to Top",
                                      bgColor: Colors.white,
                                      textColor: const Color(0xFFCA2E55),
                                      onPressed: () {
                                        _scrollController.animateTo(
                                          0,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                    ),
                                    // Back Home
                                    GradientButton(
                                      text: "Back Home",
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CatalogPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
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
