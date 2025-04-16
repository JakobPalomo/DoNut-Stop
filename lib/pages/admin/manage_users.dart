import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itelec_quiz_one/components/data_table.dart';
import 'package:itelec_quiz_one/components/pagination.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';
import 'package:intl/intl.dart';

class ManageUsersPage extends StatefulWidget {
  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int activeFilterIndex = 0; // Track the active filter index

  // Table
  final List<Map<String, dynamic>> users = [
    {"username": "alice", "role": "Admin", "createdAt": "2024-01-10T10:30:00"},
    {"username": "bob", "role": "Customer", "createdAt": "2024-03-05T14:20:00"},
    {
      "username": "carol",
      "role": "Employee",
      "createdAt": "2023-12-22T09:15:00"
    },
    {
      "username": "dave",
      "role": "Customer",
      "createdAt": "2024-02-28T17:45:00"
    },
    {"username": "eve", "role": "Admin", "createdAt": "2024-01-01T12:00:00"},
    {
      "username": "frank",
      "role": "Employee",
      "createdAt": "2024-03-15T08:30:00"
    },
    {
      "username": "grace",
      "role": "Customer",
      "createdAt": "2023-11-10T11:10:00"
    },
  ];

  final List<Map<String, dynamic>> columns = [
    {
      "label": "Username",
      "column": "username",
      "sortable": true,
      "type": "string"
    },
    {"label": "Role", "column": "role", "sortable": true, "type": "string"},
    {
      "label": "Created At",
      "column": "createdAt",
      "sortable": true,
      "type": "date"
    },
  ];

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
              padding: EdgeInsets.fromLTRB(25, 20, 25, 16),
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

            // Filter Tabs
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
                    spacing: 0,
                    runSpacing: 0,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3 - 16,
                        child: FilterButton(
                          title: "Customers",
                          color: Color(0xFFFFB957),
                          activeColor: Color(0xFFFFE7C7),
                          count: 10,
                          isActive: activeFilterIndex == 0,
                          onTap: () {
                            setState(() {
                              activeFilterIndex = 0;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3 - 16,
                        child: FilterButton(
                          title: "Employees",
                          color: Color(0xFFFF7859),
                          activeColor: Color(0xFFFFD7C5),
                          count: 5,
                          isActive: activeFilterIndex == 1,
                          onTap: () {
                            setState(() {
                              activeFilterIndex = 1;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3 - 16,
                        child: FilterButton(
                          title: "Admin",
                          color: Color(0xFFFF8BA8),
                          activeColor: Color(0xFFFFD7E0),
                          count: 2,
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

            // Main Content (CustomDataTable and Pagination)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 23),
                child: Column(
                  children: [
                    Expanded(
                      // Wrap CustomDataTable in Expanded to provide bounded height
                      child: CustomDataTable(
                        data: users,
                        columns: columns,
                        rowsPerPage: 15,
                        page: currentPage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
