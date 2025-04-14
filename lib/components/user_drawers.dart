import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/pages/catalog_page.dart';
import 'package:itelec_quiz_one/pages/product_page.dart';
import 'package:itelec_quiz_one/pages/registration_page.dart';
import 'package:itelec_quiz_one/pages/login_page.dart';
import 'package:itelec_quiz_one/pages/cart_page.dart';
import 'package:itelec_quiz_one/pages/product_management_page.dart';
import 'package:itelec_quiz_one/pages/my_orders_page.dart'; // Add this import
import 'package:itelec_quiz_one/main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
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
        _buildDrawerItem("Manage Orders", 'assets/icons/manageorders.png', MyApp(), context),
        _buildDrawerItem(
            "Manage Donuts", 'assets/icons/managedonuts.png', CatalogPage(), context),
        _buildDrawerItem(
            "Manage Users", 'assets/icons/manageusers.png', ProductPage(), context),
        _buildDrawerItem("Register", 'assets/icons/register.png',
            RegistrationPage(), context),
        _buildDrawerItem(
            "Profile", 'assets/icons/profile.png', LoginPage(), context),
        _buildDrawerItem(
            "Logout", 'assets/icons/logout.png', ProductPage(), context),
        ListTile(

          title: Text(
            "Product Management",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Color(0xFF462521),
              fontSize: 16,
            ),
          ),
          leading: Container(
            padding: const EdgeInsets.only(left: 15, right: 5),
            child: Icon(Icons.manage_accounts, color: Color(0xFF462521)),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductManagementPage()),
          ),
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
        _buildDrawerItem("Manage Orders", 'assets/icons/manageorders.png', MyApp(), context),
        _buildDrawerItem(
            "Profile", 'assets/icons/profile.png', LoginPage(), context),
        _buildDrawerItem(
            "Logout", 'assets/icons/logout.png', ProductPage(), context),
        ListTile(

          title: Text(
            "Product Management",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Color(0xFF462521),
              fontSize: 16,
            ),
          ),
          leading: Container(
            padding: const EdgeInsets.only(left: 15, right: 5),
            child: Icon(Icons.manage_accounts, color: Color(0xFF462521)),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductManagementPage()),
          ),
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
        _buildDrawerItem("Catalog", 'assets/icons/home.png', MyApp(), context),
        _buildDrawerItem(
            "My Cart", 'assets/icons/cart.png', CatalogPage(), context),
        _buildDrawerItem(
            "My Orders", 'assets/icons/myorders.png', MyOrdersPage(), context), // Update this line
        _buildDrawerItem(
            "Favorites", 'assets/icons/favorites.png', LoginPage(), context),
            _buildDrawerItem(
            "Profile", 'assets/icons/profile.png', ProductManagementPage(), context),
        _buildDrawerItem(
            "Logout", 'assets/icons/logout.png', ProductPage(), context),
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
