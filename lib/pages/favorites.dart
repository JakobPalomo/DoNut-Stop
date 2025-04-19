import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyFavoritesPage extends StatefulWidget {
  const MyFavoritesPage({super.key});

  @override
  State<MyFavoritesPage> createState() => _MyFavoritesPageState();
}

class _MyFavoritesPageState extends State<MyFavoritesPage> {
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!userSnapshot.hasData || userSnapshot.data!['favorites'] == null) {
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

              final favoriteIds = List<String>.from(userSnapshot.data!['favorites']);

              if (favoriteIds.isEmpty) {
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
                    .where(FieldPath.documentId, whereIn: favoriteIds)
                    .snapshots(),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
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

                  final favoriteProducts = productSnapshot.data!.docs;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2, // Adjust columns based on screen width
                      crossAxisSpacing: 16.0, // Space between columns
                      mainAxisSpacing: 16.0, // Space between rows
                      childAspectRatio: .65, // Ensures consistent width-to-height ratio
                    ),
                    itemCount: favoriteProducts.length,
                    itemBuilder: (context, index) {
                      final product = favoriteProducts[index];

                      return SizedBox(
                        width: 200, // Fixed width
                        height: 450, // Fixed height
                        child: SingleChildScrollView( // Added to prevent overflow
                          child: Container(
                            margin: EdgeInsets.only(right: 20),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    print("Navigating to ProductPage with:");
                                    print("Image: assets/front_donut/fdonut${index + 1}.png");
                                    print("Title: ${product['name']}\nDescription: ${product['description']}\nNew Price: ₱${product['price'].toStringAsFixed(2)}");
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  splashColor: Colors.brown.withOpacity(0.2),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFEEE1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.fromLTRB(10, 40, 10, 0),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Image.asset(
                                                  "assets/front_donut/fdonut${index + 1}.png",
                                                  width: 180,
                                                  height: 180,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 10,
                                              left: 0,
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.favorite,
                                                  color: Color(0xFFCA2E55),
                                                ),
                                                onPressed: () async {
                                                  final userId = FirebaseAuth.instance.currentUser?.uid;
                                                  if (userId != null) {
                                                    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
                                                    await userDoc.update({
                                                      'favorites': FieldValue.arrayRemove([product.id]),
                                                    });
                                                  }
                                                },
                                                padding: EdgeInsets.all(5),
                                                constraints: BoxConstraints(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 12),
                                        Container(
                                          padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product['name'],
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: Color(0xFF462521),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                product['description'],
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12,
                                                  color: Color(0xFF665A49),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  SizedBox(width: 10),
                                                  Text(
                                                    '₱${product['price'].toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 22,
                                                      color: Colors.black,
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
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
