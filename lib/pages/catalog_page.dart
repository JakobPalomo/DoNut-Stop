import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itelec_quiz_one/pages/all_donuts.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(50, 35, 50, 25),
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
              CatalogPageTodaysOffers(
                  searchQuery: _searchQuery), // Pass search query
              CatalogPageDonuts(searchQuery: _searchQuery), // Pass search query
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class ToggleChipsRow extends StatefulWidget {
  final List<String> chips;
  final Function(String) onChipSelected; // Callback for chip selection

  const ToggleChipsRow(
      {required this.chips, required this.onChipSelected, super.key});

  @override
  _ToggleChipsRowState createState() => _ToggleChipsRowState();
}

class _ToggleChipsRowState extends State<ToggleChipsRow> {
  String selectedChip = "";

  @override
  void initState() {
    super.initState();
    // setState(() {
    //   selectedChip = widget.chips.first;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: Wrap(
          spacing: 8, // Space between chips
          runSpacing: 8, // Space between rows of chips
          children: widget.chips.map((chip) => _buildChip(chip)).toList(),
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
              // If the chip is already selected, deselect it
              if (isSelected) {
                selectedChip = "";
                widget.onChipSelected("");
              } else {
                selectedChip = label;
                widget.onChipSelected(label);
              }
            });
            debugPrint("Selected Chip: $selectedChip");
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OfferSelectionWidget extends StatefulWidget {
  final String image, title, description, newPrice, productId;
  final bool isFavInitial;
  final Future<void> Function()? onFavoriteToggle;

  OfferSelectionWidget({
    required this.image,
    required this.title,
    required this.description,
    required this.newPrice,
    required this.productId,
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
        cursor: SystemMouseCursors.click,
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
                    productId: widget.productId,
                    image: widget.image,
                    title: widget.title,
                    description: widget.description,
                    newPrice: widget.newPrice,
                    isFavInitial: isFav,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.brown.withOpacity(0.2),
            child: Ink(
              decoration: BoxDecoration(
                color: Color(0xFFFFEEE1),
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
                                ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 0,
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: Color(0xFFCA2E55),
                          ),
                          onPressed: () async {
                            setState(() {
                              isFav = !isFav;
                            });
                            if (widget.onFavoriteToggle != null) {
                              await widget.onFavoriteToggle!();
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
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
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
                        SizedBox(height: 10),
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
  final String image, title, newPrice, productId, description;

  DonutSelectionWidget({
    required this.productId,
    required this.image,
    required this.title,
    required this.newPrice,
    required this.description,
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
                        productId: productId,
                        image: image,
                        title: title,
                        description: description,
                        newPrice: newPrice,
                      ),
                    ),
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
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
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
                              productId: productId,
                              image: image,
                              title: title,
                              description: description,
                              newPrice: newPrice,
                            ),
                          ),
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
  final String searchQuery;

  const CatalogPageTodaysOffers({super.key, required this.searchQuery});

  @override
  _CatalogPageTodaysOffersState createState() =>
      _CatalogPageTodaysOffersState();
}

class _CatalogPageTodaysOffersState extends State<CatalogPageTodaysOffers> {
  final ScrollController _scrollController = ScrollController();
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  Map<String, dynamic>? userData;
  Timer? _scrollTimer;

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

  void _startScrollingLeft() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _scrollController.animateTo(
        _scrollController.offset - 100, // Adjust the scroll step
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    });
  }

  void _startScrollingRight() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _scrollController.animateTo(
        _scrollController.offset + 100, // Adjust the scroll step
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    });
  }

  void _stopScrolling() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

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

    var userFavorites = userData!['favorites'] ?? [];

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
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
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Stack(children: [
            // Donut selection list with margin
            SizedBox(
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
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFDC345E)),
                        backgroundColor: Color(0xFFFF7171),
                        strokeWidth: 5.0,
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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

                  final offers = snapshot.data!.docs.where((doc) {
                    final name = doc['name'].toString().toLowerCase();
                    final description =
                        doc['description'].toString().toLowerCase();
                    final price = doc['price'].toString().toLowerCase();
                    return name.contains(widget.searchQuery) ||
                        description.contains(widget.searchQuery) ||
                        price.contains(widget.searchQuery);
                  }).toList();

                  return ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: offers.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // left padding
                        return const SizedBox(width: 50);
                      }
                      if (index == offers.length + 1) {
                        // right padding
                        return const SizedBox(width: 32);
                      }

                      final offer = offers[index - 1];
                      final productId = offer.id;

                      return OfferSelectionWidget(
                        productId: productId,
                        image: offer['image'],
                        title: offer['name'],
                        description: offer['description'],
                        newPrice: '₱${offer['price'].toStringAsFixed(2)}',
                        isFavInitial: userFavorites.contains(productId),
                        onFavoriteToggle: () async {
                          await toggleFavoriteStatus(
                            userData!['id'],
                            productId,
                            userData as Map<String, dynamic>,
                            userFavorites.contains(productId),
                            offer['name'],
                          );

                          // Refresh userFavorites
                          setState(() {
                            userFavorites = userData!['favorites'] ?? [];
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
            // Left gradient and button
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFFFE0B6),
                      Color(0x80FFE0B6),
                      Color(0x00FFE0B6),
                    ],
                  ),
                ),
                child: GestureDetector(
                  onLongPress: _startScrollingLeft,
                  onLongPressUp: _stopScrolling,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      color: Color(0xFF462521),
                      onPressed: _scrollLeft,
                    ),
                  ),
                ),
              ),
            ),
            // Right gradient and button
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Color(0xFFFFE0B6),
                      Color(0x80FFE0B6),
                      Color(0x00FFE0B6),
                    ],
                  ),
                ),
                child: GestureDetector(
                  onLongPress: _startScrollingRight,
                  onLongPressUp: _stopScrolling,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      color: Color(0xFF462521),
                      onPressed: _scrollRight,
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class CatalogPageDonuts extends StatefulWidget {
  final String searchQuery;

  const CatalogPageDonuts({super.key, required this.searchQuery});

  @override
  _CatalogPageDonutsState createState() => _CatalogPageDonutsState();
}

class _CatalogPageDonutsState extends State<CatalogPageDonuts> {
  final ScrollController _scrollController = ScrollController();
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  Map<String, dynamic>? userData;
  Timer? _scrollTimer;
  String selectedChip = ""; // Track the selected chip

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _startScrollingLeft() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _scrollController.animateTo(
        _scrollController.offset - 100, // Adjust the scroll step
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    });
  }

  void _startScrollingRight() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _scrollController.animateTo(
        _scrollController.offset + 100, // Adjust the scroll step
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    });
  }

  void _stopScrolling() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
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

  void _onChipSelected(String chip) {
    setState(() {
      selectedChip = chip;
    });
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
            padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
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
                  // See More
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        debugPrint("See More clicked");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllDonutsPage(),
                          ),
                        );
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
          // Chips
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 5, 50, 5),
            child: ToggleChipsRow(
              chips: [
                "Strawberry",
                "Chocolate",
                "Matcha",
                "Cotton Candy",
                "Glaze",
                "Ube"
              ],
              onChipSelected: _onChipSelected,
            ),
          ),
          // Donut selection list with margin
          Stack(
            children: [
              SizedBox(
                height: 265,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFDC345E)),
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

                    final donuts = snapshot.data!.docs.where((doc) {
                      final name = doc['name'].toString().toLowerCase();
                      final description =
                          doc['description'].toString().toLowerCase();
                      final price = doc['price'].toString().toLowerCase();

                      // Filter by search query and selected chip
                      final matchesSearchQuery =
                          name.contains(widget.searchQuery) ||
                              description.contains(widget.searchQuery) ||
                              price.contains(widget.searchQuery);

                      final matchesChip = selectedChip.isEmpty ||
                          name.contains(selectedChip.toLowerCase());

                      return matchesSearchQuery && matchesChip;
                    }).toList();

                    return ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: donuts.length + 2,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // left padding
                          return const SizedBox(width: 50);
                        }
                        if (index == donuts.length + 1) {
                          // right padding
                          return const SizedBox(width: 32);
                        }

                        final donut = donuts[index - 1];
                        final productId = donut.id;

                        return DonutSelectionWidget(
                          productId: productId,
                          image: donut['image'] ?? "",
                          title: donut['name'],
                          newPrice: '₱${donut['price'].toStringAsFixed(2)}',
                          description: donut['description'],
                        );
                      },
                    );
                  },
                ),
              ),
              // Left gradient and button
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFFFE0B6),
                        Color(0x80FFE0B6),
                        Color(0x00FFE0B6),
                      ],
                    ),
                  ),
                  child: SizedBox(
                    height: 50,
                    child: GestureDetector(
                      onLongPress: _startScrollingLeft,
                      onLongPressUp: _stopScrolling,
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          color: Color(0xFF462521),
                          onPressed: _scrollLeft,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Right gradient and button
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Color(0xFFFFE0B6),
                        Color(0x80FFE0B6),
                        Color(0x00FFE0B6),
                      ],
                    ),
                  ),
                  child: GestureDetector(
                    onLongPress: _startScrollingRight,
                    onLongPressUp: _stopScrolling,
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        color: Color(0xFF462521),
                        onPressed: _scrollRight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                  // More Donuts Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF7171), Color(0xFFDC345E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllDonutsPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 18, horizontal: 30),
                      ),
                      child: Text(
                        "More Donuts",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
