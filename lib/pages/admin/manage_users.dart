import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itelec_quiz_one/components/pagination.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';

class ManageUsersPage extends StatefulWidget {
  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> user = [];
  int activeFilterIndex = 0; // Track the active filter index

  // Pagination variables
  int currentPage = 1; // Initial page
  final int totalPages = 5; // Total number of pages

  void _handlePageChange(int newPage) {
    setState(() {
      currentPage = newPage; // Update the current page
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDummyData();
  }

  void _loadDummyData() {
    // Sample dummy data for orders
    final List<Map<String, dynamic>> dummyOrders = List.generate(
      15,
      (index) => {
        'username': 'Asherbiggie',
        'role': 'Customer',
      },
    );

    setState(() {
      user = dummyOrders;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Manage Users",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFFFE0B6),
        appBar: AppBarWithMenuAndTitle(title: "Manage Users"),
        drawer: AdminDrawer(),
        body: Column(
          children: [
            // Search Bar
            Container(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                height: 42,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    focusColor: Color(0xFF684440),
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: Colors.white,
                      selectionColor: Color(0xFF684440),
                      selectionHandleColor: Color(0xFF684440),
                    ),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      filled: true,
                      fillColor: Colors.brown.shade800,
                      hintStyle: TextStyle(color: Colors.white70),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Icon(Icons.search, color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    cursorColor: Colors.white,
                  ),
                ),
              ),
            ),

            // Filter tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFFEEE1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFD0B8A4),
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                    left: BorderSide(
                      color: Color(0xFFD0B8A4),
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                    right: BorderSide(
                      color: Color(0xFFD0B8A4),
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Wrap(
                    spacing: 0, // Add spacing between buttons
                    runSpacing:
                        0, // Add spacing between rows if wrapping occurs
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3 -
                            0, // Divide width evenly
                        child: FilterButton(
                          title: "Customers",
                          color: Color(0xFFFFB957),
                          activeColor: Color(0xFFFFE7C7),
                          count: 10, // Replace with actual count
                          isActive: activeFilterIndex == 0,
                          onTap: () {
                            setState(() {
                              activeFilterIndex = 0;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3 -
                            8, // Divide width evenly
                        child: FilterButton(
                          title: "Employees",
                          color: Color(0xFFFF7859),
                          activeColor: Color(0xFFFFD7C5),
                          count: 5, // Replace with actual count
                          isActive: activeFilterIndex == 1,
                          onTap: () {
                            setState(() {
                              activeFilterIndex = 1;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3 -
                            27, // Divide width evenly
                        child: FilterButton(
                          title: "Admin",
                          color: Color(0xFFFF8BA8),
                          activeColor: Color(0xFFFFD7E0),
                          count: 2, // Replace with actual count
                          isActive: activeFilterIndex == 2,
                          onTap: () {
                            setState(() {
                              activeFilterIndex = 2;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Table
            Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(children: [
                  // Headers
                  Container(
                    color: Color(0xFFDC345E),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Username',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Role',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(), // Space for view button
                        ),
                      ],
                    ),
                  ),
                ])),

            // Order list
            Expanded(
              child: ListView.builder(
                itemCount: user.length,
                itemBuilder: (context, index) {
                  final indivUser = user[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Row(
                        children: [
                          // Username
                          Expanded(
                            flex: 2,
                            child: Text(
                              indivUser['username'],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          // Status
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButton<String>(
                                value: indivUser['role'],
                                isExpanded: true,
                                isDense: true,
                                underline: Container(),
                                items: [
                                  'Customer',
                                  'Employee',
                                  'Admin',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    user[index]['role'] = newValue;
                                  });
                                },
                              ),
                            ),
                          ),

                          // View button
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              icon: Icon(
                                Icons.visibility,
                                color: Color(0xFFCA2E55),
                              ),
                              onPressed: () {
                                // View user details
                              },
                            ),
                          ),

                          // Edit button
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Color(0xFFCA2E55),
                              ),
                              onPressed: () {
                                // View user details
                              },
                            ),
                          ),

                          // Delete button
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Color(0xFFCA2E55),
                              ),
                              onPressed: () {
                                // View user details
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Pagination
            Pagination(
                currentPage: currentPage,
                totalPages: totalPages,
                onPageChange: (int page) {
                  print("Go to page $page");
                  _handlePageChange(page);
                })
          ],
        ),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String title;
  final Color color; // Bottom border color and badge background color
  final Color activeColor; // Background color when selected
  final int count; // Badge count
  final bool isActive; // Whether the button is active
  final VoidCallback onTap; // Callback when the button is tapped

  const FilterButton({
    super.key,
    required this.title,
    required this.color,
    required this.activeColor,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? activeColor : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withOpacity(0.1),
        hoverColor: color.withOpacity(0.1),
        focusColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.2),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? color : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min, // Prevent taking full width
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFF462521),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      color: Color(0xFF462521),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
