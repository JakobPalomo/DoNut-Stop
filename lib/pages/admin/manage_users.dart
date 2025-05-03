import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:donut_stop/components/buttons.dart';
import 'package:donut_stop/components/data_table.dart';
import 'package:donut_stop/components/pagination.dart';
import 'package:donut_stop/components/user_drawers.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donut_stop/pages/admin/view_edit_user.dart';
import 'package:toastification/toastification.dart';

class ManageUsersPage extends StatefulWidget {
  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final TextEditingController _searchController = TextEditingController();

  void _deleteUser(String id) async {
    // await _usersCollection.doc(id).delete();
    await _usersCollection.doc(id).update({'is_deleted': true});
    // Trigger the onDataChanged callback to update the filter counts
    // setState(() {});
    toastification.show(
      context: context,
      title: Text('User Deleted'),
      description: Text('User has been deleted successfully.'),
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  void _updateUserRole(String id, int newRole) async {
    // Fetch the current role from Firestore
    final userDoc = await _usersCollection.doc(id).get();
    final currentRole = (userDoc.data() as Map<String, dynamic>?)?['role'];

    // Check if the role is already the same
    if (currentRole == newRole) {
      return;
    }

    // Proceed with the update if the role has changed
    await _usersCollection.doc(id).update({'role': newRole});

    // Show a success message
    toastification.show(
      context: context,
      title: Text('User Updated'),
      description: Text('User role has been updated successfully.'),
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  // Filter data
  final List<Map<String, dynamic>> filters = [
    {
      "label": "All",
      "value": 0,
      "count": 0,
      "color": Color(0xFFCE895B),
      "activeColor": Color(0xFFF9DBB3),
    },
    {
      "label": "Customer",
      "value": 1,
      "count": 0,
      "color": Color(0xFFFFB957),
      "activeColor": Color(0xFFFFE7C7),
    },
    {
      "label": "Employee",
      "value": 2,
      "count": 0,
      "color": Color(0xFFFF7859),
      "activeColor": Color(0xFFFFD7C5),
    },
    {
      "label": "Admin",
      "value": 3,
      "count": 0,
      "color": Color(0xFFFF8BA8),
      "activeColor": Color(0xFFFFD7E0),
    },
  ];
  // Table data
  final List<Map<String, dynamic>> dummyUsers = [
    {"username": "alice", "role": 3, "created_at": "2024-01-10T10:30:00"},
    {"username": "bob", "role": 1, "created_at": "2024-03-05T14:20:00"},
    {"username": "carol", "role": 2, "created_at": "2023-12-22T09:15:00"},
    {"username": "dave", "role": 1, "created_at": "2024-02-28T17:45:00"},
    {"username": "eve", "role": 3, "created_at": "2024-01-01T12:00:00"},
    {"username": "frank", "role": 2, "created_at": "2024-03-15T08:30:00"},
    {"username": "grace", "role": 1, "created_at": "2023-11-10T11:10:00"},
  ];

  final List<Map<String, dynamic>> columns = [
    {
      "label": "Username",
      "column": "username",
      "sortable": true,
      "type": "string",
      "width": 120
    },
    {
      "label": "Role",
      "column": "role",
      "sortable": true,
      "type": "string",
      "width": 140
    },
    {
      "label": "Created At",
      "column": "created_at",
      "sortable": true,
      "type": "date",
      "width": 110,
    },
    {
      "label": "First Name",
      "column": "first_name",
      "sortable": true,
      "type": "string",
      "width": 120
    },
    {
      "label": "Last Name",
      "column": "last_name",
      "sortable": true,
      "type": "string",
      "width": 120
    },
    {
      "label": "Email Address",
      "column": "email",
      "sortable": true,
      "type": "string",
      "width": 200
    },
    {
      "label": "Contact No.",
      "column": "contact_no",
      "sortable": false,
      "type": "string",
      "width": 110
    },
    {
      "label": "Address",
      "column": "address",
      "sortable": true,
      "type": "string",
      "width": 500
    },
    {
      "label": "",
      "column": "actions",
      "sortable": false,
      "type": "actions",
      "width": 120,
    },
  ];
  final List<Map<String, Object>> dropdowns = [
    {
      "row": "role",
      "options": [
        {"label": "Customer", "value": 1},
        {"label": "Employee", "value": 2},
        {"label": "Admin", "value": 3},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller to avoid memory leaks
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            Container(
              padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 16.0),
              child: SizedBox(
                height: 42.0,
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
                    controller: _searchController,
                    onChanged: (query) {
                      setState(() {}); // Trigger a rebuild to pass the query
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      filled: true,
                      fillColor: Colors.brown.shade800,
                      hintStyle: TextStyle(color: Colors.white70),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Icon(Icons.search, color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                    cursorColor: Colors.white,
                  ),
                ),
              ),
            ),

            // Main Content (StreamBuilder and Pagination)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 23),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _usersCollection
                      .orderBy('created_at', descending: true)
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
                      // Update filter counts to 0 if no users are found
                      for (var filter in filters) {
                        filter['count'] = 0;
                      }
                      return const Center(
                          child: Text(
                        'No users found.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC7A889),
                        ),
                      ));
                    }

                    // Fetch users and their subcollections
                    final usersFuture = Future.wait(
                      snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        // If `is_deleted` is missing or false, include the doc
                        return !(data['is_deleted'] == true);
                      }).map((doc) async {
                        final data = doc.data() as Map<String, dynamic>;

                        // Fetch the locations subcollection
                        final locationsSnapshot =
                            await doc.reference.collection('locations').get();
                        final locations =
                            locationsSnapshot.docs.map((locationDoc) {
                          return {
                            ...locationDoc.data(),
                            "id": locationDoc.id,
                          };
                        }).toList();

                        // Find the main location and format the address
                        final mainLocation = locations.firstWhere(
                          (location) => location['main_location'] == true,
                          orElse: () => {},
                        );

                        final formattedAddress = mainLocation.isNotEmpty
                            ? "${mainLocation['house_no_building_street'] ?? ''}, "
                                "Brgy. ${mainLocation['barangay'] ?? ''}, "
                                "${mainLocation['city_municipality'] ?? ''}, "
                                "${mainLocation['state_province'] ?? ''}, "
                                "${mainLocation['zip']?.toString() ?? ''}"
                            : 'No address available';

                        // Combine user data with locations and formatted address
                        return {
                          ...data,
                          "id": doc.id,
                          "locations": locations,
                          "address":
                              formattedAddress, // Add the formatted address
                          "created_at": data['created_at'] is Timestamp
                              ? DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                                  .format(data['created_at'].toDate())
                              : "2024-01-10T10:30:00",
                          "modified_at": data['modified_at'] is Timestamp
                              ? DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                                  .format(data['modified_at'].toDate())
                              : "2024-01-10T10:30:00",
                        };
                      }).toList(),
                    );

                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: usersFuture,
                      builder: (context, usersSnapshot) {
                        if (usersSnapshot.connectionState ==
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

                        if (!usersSnapshot.hasData ||
                            usersSnapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No users found.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFC7A889),
                                  )));
                        }

                        final users = usersSnapshot.data!;

                        // Dynamically update filter counts
                        for (var filter in filters) {
                          if (filter['value'] == 0) {
                            // "All" filter
                            filter['count'] = users.length;
                          } else {
                            // Role-specific filters
                            filter['count'] = users
                                .where(
                                    (user) => user['role'] == filter['value'])
                                .length;
                          }
                        }

                        return CustomDataTable(
                          data: users,
                          columns: columns,
                          filters: filters,
                          rowsPerPage: 12,
                          searchQuery: _searchController.text,
                          dropdowns: dropdowns,
                          onRoleChanged: (row, newRole) {
                            _updateUserRole(row['id'], newRole);
                          },
                          actionsBuilder: (row) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility,
                                      color: Color(0xFFCA2E55)),
                                  onPressed: () {
                                    // Handle view action
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ViewEditUserPage(user: row)),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Color(0xFFCA2E55)),
                                  onPressed: () {
                                    // Handle edit action
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ViewEditUserPage(
                                                  isEditing: true, user: row)),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Color(0xFFCA2E55)),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          titlePadding: const EdgeInsets.all(0),
                                          actionsAlignment:
                                              MainAxisAlignment.center,
                                          title: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFCA2E55),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                            child: const Text(
                                              "Confirm Deletion",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Inter',
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          content: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                20, 15, 20, 5),
                                            child: Text(
                                              "Are you sure you want to delete this user?",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            Wrap(
                                                alignment: WrapAlignment.center,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                spacing: 10,
                                                runSpacing: 10,
                                                children: [
                                                  CustomOutlinedButton(
                                                    text: "Cancel",
                                                    bgColor: Colors.white,
                                                    textColor:
                                                        Color(0xFFCA2E55),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  GradientButton(
                                                    text: "Delete",
                                                    onPressed: () {
                                                      _deleteUser(row['id']);
                                                      Navigator.of(context)
                                                          .pop();
                                                      toastification.show(
                                                        context: context,
                                                        title: Text(
                                                            'User deleted'),
                                                        description: Text(
                                                            'User ${row['username']}has been deleted.'),
                                                        type: ToastificationType
                                                            .success,
                                                        autoCloseDuration:
                                                            const Duration(
                                                                seconds: 4),
                                                      );
                                                    },
                                                  ),
                                                ])
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
