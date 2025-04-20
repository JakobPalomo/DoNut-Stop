import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/pages/product_page.dart';
import 'package:itelec_quiz_one/pages/cart_page.dart';
import 'package:itelec_quiz_one/pages/product_management_page.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:itelec_quiz_one/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';
import 'package:itelec_quiz_one/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // For Base64 encoding

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
    });
  }

  void _checkUserSession(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      toastification.show(
        context: context,
        title: Text('Access Denied'),
        description: Text('You are not logged in yet.'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 4),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkUserSession(context); // Check session on page load
    return MaterialApp(
      title: "Catalog Page Module",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFE0B6),
      ),
      home: Scaffold(
        appBar: AppBarWithSearchAndCart(),
        drawer: UserDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(35, 35, 35, 25),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text(
                        "Welcome back, ${username ?? 'User'}!",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF462521),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Order your favourite donuts from here!",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF665A49),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const CatalogPageTodaysOffers(),
              const CatalogPageDonuts(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class ToggleChipsRow extends StatefulWidget {
  @override
  _ToggleChipsRowState createState() => _ToggleChipsRowState();
}

class _ToggleChipsRowState extends State<ToggleChipsRow> {
  String selectedChip = "Strawberry"; // Default selected chip

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: Row(
          children: [
            SizedBox(width: 35),
            _buildChip("Strawberry"),
            SizedBox(width: 8),
            _buildChip("Chocolate"),
            SizedBox(width: 8),
            _buildChip("Matcha"),
            SizedBox(width: 8),
            _buildChip("Cotton Candy"),
            SizedBox(width: 8),
            _buildChip("Glazed"),
            SizedBox(width: 8),
            _buildChip("Ube"),
            SizedBox(width: 35),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    bool isSelected = selectedChip == label;

    return MouseRegion(
      cursor: SystemMouseCursors.click, // Shows cursor effect
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedChip = label;
            });
            debugPrint("Selected Today's Offers: $label");
          },
          borderRadius: BorderRadius.circular(20), // Circle ripple
          splashColor: Colors.white.withOpacity(0.3), // White ripple effect
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFCA2E55) : Color(0xFFFFEEE1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                    fontFamily: 'Inter',
                    color: isSelected ? Colors.white : Color(0xFF665A49),
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OfferSelectionWidget extends StatefulWidget {
  final String image, title, description, newPrice;
  final bool isFavInitial;
  final VoidCallback? onFavoriteToggle;

  OfferSelectionWidget({
    required this.image,
    required this.title,
    required this.description,
    required this.newPrice,
    this.isFavInitial = false,
    this.onFavoriteToggle,
  });

  @override
  _OfferSelectionWidgetState createState() => _OfferSelectionWidgetState();
}

class _OfferSelectionWidgetState extends State<OfferSelectionWidget> {
  late bool isFav;

  @override
  void initState() {
    super.initState();
    isFav = widget.isFavInitial;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      child: MouseRegion(
        cursor: SystemMouseCursors.click, // Shows pointer cursor on hover
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              print("Navigating to ProductPage with:");
              print("Image: ${widget.image}");
              print("Title: ${widget.title}");
              print("Description: ${widget.description}");
              print("New Price: ${widget.newPrice}");

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductPage(
                          productId: widget.title,
                          image: widget.image,
                          title: widget.title,
                          description: widget.description,
                          newPrice: widget.newPrice,
                        )),
              );
            },
            borderRadius:
                BorderRadius.circular(16), // Ensures ripple follows shape
            splashColor: Colors.brown.withOpacity(0.2), // Ripple effect color
            child: Ink(
              decoration: BoxDecoration(
                color: Color(0xFFFFEEE1), // Background color inside Ink
                borderRadius: BorderRadius.circular(16),
              ),
              width: 230,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 45, 10, 0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: widget.image.isNotEmpty &&
                                    widget.image.startsWith('data:image/')
                                ? Image.memory(
                                    base64Decode(widget.image.split(',').last),
                                    fit: BoxFit.contain,
                                    width: 180,
                                    height: 180,
                                  )
                                : Image.asset(
                                    width: 180,
                                    height: 180,
                                    widget.image.isNotEmpty
                                        ? widget.image
                                        : 'assets/front_donut/fdonut1.png',
                                    fit: BoxFit.contain,
                                  )),
                      ),
                      Positioned(
                        top: 10,
                        left: 0,
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: Color(0xFFCA2E55),
                          ),
                          onPressed: () {
                            setState(() {
                              isFav = !isFav;
                            });
                            if (widget.onFavoriteToggle != null) {
                              widget.onFavoriteToggle!();
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
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF462521),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.description,
                          maxLines: 2,
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
                              widget.newPrice,
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
    );
  }
}

class DonutSelectionWidget extends StatelessWidget {
  final String image, title, newPrice;

  DonutSelectionWidget({
    required this.image,
    required this.title,
    required this.newPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      width: 200, // Adjusted width for better donut display
      child: Stack(
        clipBehavior: Clip.none, // Allows image to extend outside the container
        children: [
          // Donut Info Container (with ripple effect)
          Positioned(
            top: 120,
            child: Material(
              color: Colors.transparent, // Prevents ripple from being hidden
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductPage(
                              productId: title,
                              image: image,
                              title: title,
                              newPrice: newPrice,
                            )),
                  );
                },
                borderRadius:
                    BorderRadius.circular(16), // Ensures ripple follows shape
                splashColor:
                    Colors.brown.withOpacity(0.2), // Ripple effect color
                child: Ink(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFEEE1), // Background color inside Ink
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: 200,
                    margin: EdgeInsets.only(
                        top: 20), // Ensures image extends outside
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SizedBox(height: 30), // Space for donut image
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF462521),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          newPrice,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            color: Color(0xFF000000),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Donut Image (Clickable but no ripple effect)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Positioned(
                top: -15, // Moves the image slightly upwards
                left: 20,
                right: 20,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click, // Shows pointer cursor
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductPage(
                                    productId: title,
                                    image: image,
                                    title: title,
                                    newPrice: newPrice,
                                  )),
                        );
                      },
                      child: image.isNotEmpty && image.startsWith('data:image/')
                          ? Image.memory(
                              base64Decode(image.split(',').last),
                              fit: BoxFit.contain,
                              width: 180,
                              height: 180,
                            )
                          : Image.asset(
                              width: 180,
                              height: 180,
                              image.isNotEmpty
                                  ? image
                                  : 'assets/front_donut/fdonut1.png',
                              fit: BoxFit.contain,
                            )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CatalogPageTodaysOffers extends StatefulWidget {
  const CatalogPageTodaysOffers({super.key});

  @override
  _CatalogPageTodaysOffersState createState() =>
      _CatalogPageTodaysOffersState();
}

class _CatalogPageTodaysOffersState extends State<CatalogPageTodaysOffers> {
  final ScrollController _scrollController = ScrollController();
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final auth = FirebaseAuth.instance;
    final data =
        await fetchAuthenticatedUserData(auth, _usersCollection, context);
    if (data != null) {
      setState(() {
        userData = data;
      });
    }
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC345E)),
          backgroundColor: Color(0xFFFF7171),
          strokeWidth: 5.0,
        ),
      );
    }

    final userFavorites = userData!['favorites'] ?? [];

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(35, 0, 35, 0),
            child: Container(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 20,
                runSpacing: 5,
                children: [
                  Text(
                    "Today's Offers",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        debugPrint("See More clicked");
                      },
                      borderRadius: BorderRadius.circular(20),
                      splashColor: Colors.white.withOpacity(0.3),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Text(
                          "See More",
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
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: _scrollLeft,
              ),
              Expanded(
                child: SizedBox(
                  height: 355,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .orderBy('name', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFDC345E)),
                            backgroundColor: Color(0xFFFF7171),
                            strokeWidth: 5.0,
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No offers found.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC7A889),
                            ),
                          ),
                        );
                      }

                      final offers = snapshot.data!.docs;

                      return ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          final productId = offer.id;
                          final isFavorited = userFavorites.contains(productId);

                          return OfferSelectionWidget(
                            image: offer['image'] ?? "",
                            title: offer['name'],
                            description: offer['description'],
                            newPrice: '₱${offer['price'].toStringAsFixed(2)}',
                            isFavInitial: isFavorited,
                            onFavoriteToggle: () async {
                              final userDoc = FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userData!['id']);

                              if (isFavorited) {
                                await userDoc.update({
                                  'favorites':
                                      FieldValue.arrayRemove([productId])
                                });
                              } else {
                                await userDoc.update({
                                  'favorites':
                                      FieldValue.arrayUnion([productId])
                                });
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: _scrollRight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CatalogPageDonuts extends StatefulWidget {
  const CatalogPageDonuts({super.key});

  @override
  _CatalogPageDonutsState createState() => _CatalogPageDonutsState();
}

class _CatalogPageDonutsState extends State<CatalogPageDonuts> {
  final ScrollController _scrollController = ScrollController();
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final auth = FirebaseAuth.instance;
    final data =
        await fetchAuthenticatedUserData(auth, _usersCollection, context);
    if (data != null) {
      setState(() {
        userData = data;
      });
    }
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC345E)),
          backgroundColor: Color(0xFFFF7171),
          strokeWidth: 5.0,
        ),
      );
    }

    final userFavorites = userData!['favorites'] ?? [];

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(35, 0, 35, 0),
            child: Container(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 20,
                runSpacing: 5,
                children: [
                  Text(
                    "Donuts",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        debugPrint("See More clicked");
                      },
                      borderRadius: BorderRadius.circular(20),
                      splashColor: Colors.white.withOpacity(0.3),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Text(
                          "See More",
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
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: _scrollLeft,
              ),
              Expanded(
                child: SizedBox(
                  height: 265,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFDC345E)),
                            backgroundColor: Color(0xFFFF7171),
                            strokeWidth: 5.0,
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No donuts found.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC7A889),
                            ),
                          ),
                        );
                      }

                      final donuts = snapshot.data!.docs;
                      final images = [
                        "assets/front_donut/fdonut8.png",
                        "assets/front_donut/fdonut7.png",
                        "assets/front_donut/fdonut6.png",
                        "assets/front_donut/fdonut21.png",
                        "assets/front_donut/fdonut22.png",
                      ];

                      return ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: donuts.length,
                        itemBuilder: (context, index) {
                          final donut = donuts[index];
                          final productId = donut.id;
                          final isFavorited = userFavorites.contains(productId);
                          final image = images[index % images.length];

                          return DonutSelectionWidget(
                            image: donut['image'] ?? "",
                            title: donut['name'],
                            newPrice: '₱${donut['price'].toStringAsFixed(2)}',
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: _scrollRight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<Map<String, dynamic>?> fetchAuthenticatedUserData(FirebaseAuth auth,
    CollectionReference usersCollection, BuildContext context) async {
  try {
    // Get the authenticated user's UID
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception("No authenticated user found.");
    }

    final userId = currentUser.uid;
    print("Authenticated user ID: $userId");

    // Fetch the user's main document
    final userDoc = await usersCollection.doc(userId).get();
    if (!userDoc.exists) {
      throw Exception("User document not found.");
    }

    final userData = userDoc.data() as Map<String, dynamic>;

    // Fetch the locations subcollection
    final locationsSnapshot =
        await usersCollection.doc(userId).collection('locations').get();
    final locations = locationsSnapshot.docs.map((locationDoc) {
      return {
        ...locationDoc.data(),
        "id": locationDoc.id,
      };
    }).toList();

    // Fetch the cart subcollection
    final cartSnapshot =
        await usersCollection.doc(userId).collection('cart').get();
    final cart = cartSnapshot.docs.map((cartDoc) {
      return {
        ...cartDoc.data(),
        "id": cartDoc.id,
      };
    }).toList();

    // Combine user data with locations and format timestamps
    final formattedUserData = {
      ...userData,
      "id": userId,
      "locations": locations,
      "cart": cart,
      "favorites": userData['favorites'] is List
          ? List<String>.from(userData['favorites'])
          : [],
      "created_at": userData['created_at'] is Timestamp
          ? DateFormat("yyyy-MM-dd'T'HH:mm:ss")
              .format(userData['created_at'].toDate())
          : "2024-01-10T10:30:00",
      "modified_at": userData['modified_at'] is Timestamp
          ? DateFormat("yyyy-MM-dd'T'HH:mm:ss")
              .format(userData['modified_at'].toDate())
          : "2024-01-10T10:30:00",
    };

    // Populate location controllers where main_location is true
    if (formattedUserData['locations'] != null &&
        formattedUserData['locations'] is List) {
      final mainLocation = (formattedUserData['locations'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere(
            (location) => location['main_location'] == true,
            orElse: () => <String, dynamic>{},
          );
      final formattedAddress = mainLocation.isNotEmpty
          ? "${mainLocation['house_no_building_street'] ?? ''}, "
              "Brgy. ${mainLocation['barangay'] ?? ''}, "
              "${mainLocation['city_municipality'] ?? ''}, "
              "${mainLocation['state_province'] ?? ''}, "
              "${mainLocation['zip']?.toString() ?? ''}"
          : 'No address available';

      if (mainLocation.isNotEmpty) {
        formattedUserData['main_location'] = mainLocation;
        formattedUserData['address'] = formattedAddress;
      }
    }

    print("User data fetched successfully: $formattedUserData");
    return formattedUserData;
  } catch (e) {
    print("Error fetching user data: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to fetch user data."),
        backgroundColor: Colors.red,
      ),
    );
    return null;
  }
}
