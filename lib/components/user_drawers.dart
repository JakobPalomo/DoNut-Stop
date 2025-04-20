import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/pages/admin/manage_products.dart';
import 'package:itelec_quiz_one/pages/admin/manage_users.dart';
import 'package:itelec_quiz_one/pages/catalog_page.dart';
import 'package:itelec_quiz_one/pages/favorites.dart';
import 'package:itelec_quiz_one/pages/product_page.dart';
import 'package:itelec_quiz_one/pages/profile.dart';
import 'package:itelec_quiz_one/pages/registration_page.dart';
import 'package:itelec_quiz_one/pages/login_page.dart';
import 'package:itelec_quiz_one/pages/cart_page.dart';
import 'package:itelec_quiz_one/pages/product_management_page.dart';
import 'package:itelec_quiz_one/pages/my_orders_page.dart'; // Add this import
import 'package:itelec_quiz_one/pages/admin/manage_orders.dart'; // Corrected package name
import 'package:itelec_quiz_one/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';

class AppBarWithSearchAndCart extends StatelessWidget
    implements PreferredSizeWidget {
  const AppBarWithSearchAndCart({super.key});

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFEDC690), // Background color
      elevation: 0, // Remove shadow
      scrolledUnderElevation: 0,
      title: Row(children: [
        // Square Image on the Left
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            image: DecorationImage(
              image: AssetImage("assets/mini_logo.png"),
              fit: BoxFit.contain,
            ),
          ),
        ),

        // Search Bar
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 10),
            child: SizedBox(
              height: 38,
              child: TextField(
                cursorColor: Colors.white,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF2F090B),
                  hintText: "Search products",
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 15, right: 10),
                    child: Icon(Icons.search, color: Colors.white, size: 18.0),
                  ), // Search icon
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded edges
                    borderSide: BorderSide.none, // No border
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
              ),
            ),
          ),
        ),

        // Cart Icon
        Container(
          padding: EdgeInsets.only(left: 10),
          child: IconButton(
            icon: Icon(Icons.shopping_cart, color: Color(0xFF2F090B)),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => CartPage())),
          ),
        ),
      ]),
    );
  }
}

class AppBarWithMenuAndTitle extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  const AppBarWithMenuAndTitle({required this.title, super.key});

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFEDC690), // Background color
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          // Square Logo on the Left
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                image: AssetImage("assets/mini_logo.png"),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF462521),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppBarWithBackAndTitle extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final Function? onBackPressed;
  final Color? backgroundColor;
  final Widget? trailingWidget;

  const AppBarWithBackAndTitle(
      {this.title,
      this.onBackPressed,
      this.backgroundColor,
      this.trailingWidget,
      super.key});

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(children: [
        Text(
          title ?? "",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF462521),
          ),
        ),
        Expanded(child: Container()),
        // Trailing widget (if any)
        if (trailingWidget != null) trailingWidget!,
      ]),
      backgroundColor: backgroundColor ?? Color(0xFFEDC690),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Container(
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: Image.asset(
            'assets/icons/back.png',
            width: 20,
            height: 20,
          ),
          onPressed: onBackPressed as VoidCallback? ??
              () {
                Navigator.of(context).pop();
              },
        ),
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  final Widget drawerHeader;
  final List<Widget> drawerItems;

  CustomDrawer({required this.drawerHeader, required this.drawerItems});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          drawerHeader,
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: drawerItems,
            ),
          ),
        ],
      ),
    );
  }
}

// Drawer Header
class DrawerHeaderWidget extends StatefulWidget {
  @override
  State<DrawerHeaderWidget> createState() => _DrawerHeaderWidgetState();
}

class _DrawerHeaderWidgetState extends State<DrawerHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(color: Color(0xFFFFE1B7)),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Image.asset('assets/icons/back.png', width: 20, height: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Center(
            child: Image.asset(
              'assets/main_logo.png',
              width: 220,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

// List Items
ListTile _buildDrawerItem(
    String title, String iconPath, Widget page, BuildContext context) {
  return ListTile(
    title: Text(
      title,
      style: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        color: Color(0xFF462521),
        fontSize: 16,
      ),
    ),
    leading: Container(
      padding: EdgeInsets.only(left: 15, right: 5),
      child: Image.asset(iconPath, width: 24, height: 24),
    ),
    onTap: () =>
        Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
  );
}

// Admin Drawer
class AdminDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomDrawer(
      drawerHeader: DrawerHeaderWidget(),
      drawerItems: [
        _buildDrawerItem("Manage Orders", 'assets/icons/manageorders.png',
            ManageOrdersPage(), context),
        _buildDrawerItem("Manage Products", 'assets/icons/managedonuts.png',
            ManageProductsPage(), context),
        _buildDrawerItem("Manage Users", 'assets/icons/manageusers.png',
            ManageUsersPage(), context),
        _buildDrawerItem(
            "Profile", 'assets/icons/profile.png', ProfilePage(), context),
        ListTile(
          title: Text(
            "Logout",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Color(0xFF462521),
              fontSize: 16,
            ),
          ),
          leading: Container(
            padding: EdgeInsets.only(left: 15, right: 5),
            child:
                Image.asset('assets/icons/logout.png', width: 24, height: 24),
          ),
          onTap: () => logout(context),
        ),
      ],
    );
  }
}

// Employee Drawer
class EmployeeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomDrawer(
      drawerHeader: DrawerHeaderWidget(),
      drawerItems: [
        _buildDrawerItem("Manage Orders", 'assets/icons/manageorders.png',
            ManageOrdersPage(), context),
        _buildDrawerItem(
            "Profile", 'assets/icons/profile.png', ProfilePage(), context),
        ListTile(
          title: Text(
            "Logout",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Color(0xFF462521),
              fontSize: 16,
            ),
          ),
          leading: Container(
            padding: EdgeInsets.only(left: 15, right: 5),
            child:
                Image.asset('assets/icons/logout.png', width: 24, height: 24),
          ),
          onTap: () => logout(context),
        ),
      ],
    );
  }
}

// User Drawer
class UserDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomDrawer(
      drawerHeader: DrawerHeaderWidget(),
      drawerItems: [
        _buildDrawerItem(
            "Catalog", 'assets/icons/home.png', CatalogPage(), context),
        _buildDrawerItem(
            "My Cart", 'assets/icons/cart.png', CartPage(), context),
        _buildDrawerItem(
            "My Orders", 'assets/icons/myorders.png', MyOrdersPage(), context),
        _buildDrawerItem("My Favorites", 'assets/icons/favorites.png',
            MyFavoritesPage(), context),
        _buildDrawerItem(
            "Profile", 'assets/icons/profile.png', ProfilePage(), context),
        ListTile(
          title: Text(
            "Logout",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Color(0xFF462521),
              fontSize: 16,
            ),
          ),
          leading: Container(
            padding: EdgeInsets.only(left: 15, right: 5),
            child:
                Image.asset('assets/icons/logout.png', width: 24, height: 24),
          ),
          onTap: () => logout(context),
        ),
      ],
    );
  }
}

// Guest Drawer
class GuestDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomDrawer(
      drawerHeader: DrawerHeaderWidget(),
      drawerItems: [
        _buildDrawerItem("Home", 'assets/icons/home.png', MyApp(), context),
        _buildDrawerItem("Register", 'assets/icons/register.png',
            RegistrationPage(), context),
        _buildDrawerItem(
            "Login", 'assets/icons/login.png', LoginPage(), context),
      ],
    );
  }
}

Future<void> logout(BuildContext context) async {
  try {
    // Log out the Firebase authenticated user
    await FirebaseAuth.instance.signOut();

    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all shared preferences

    // Navigate to the Login Page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );

    // Show a success message
    toastification.show(
      context: context,
      title: Text('Logged out successfully'),
      description: Text('You have been logged out.'),
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 4),
    );
  } catch (e) {
    // Handle errors
    print("Error during logout: $e");
    toastification.show(
      context: context,
      title: Text('Error logging out'),
      description: Text('An error occurred while logging out.'),
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 4),
    );
  }
}
