import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';

class ManageOrdersPage extends StatefulWidget {
  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> orderItems = [];

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
        'date': '04/07/25',
        'time': '6:00 AM',
        'reference': 'OR04072506000${index + 1}',
        'status': 'For Delivery'
      },
    );

    setState(() {
      orderItems = dummyOrders;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE0B6),
      appBar: AppBarWithMenuAndTitle(title: "Manage Orders"),
      drawer: AdminDrawer(), // or EmployeeDrawer()
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                filled: true,
                fillColor: Colors.brown.shade800,
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),

          // Filter tabs
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterTab("For Delivery", 0),
                _buildFilterTab("Shipped", 1),
                _buildFilterTab("Cancelled", 2),
              ],
            ),
          ),

          // Headers
          Container(
            color: Color(0xFFDC345E),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Date & Time',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Reference No.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Order Status',
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

          // Order list
          Expanded(
            child: ListView.builder(
              itemCount: orderItems.length,
              itemBuilder: (context, index) {
                final item = orderItems[index];
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
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: [
                        // Date and Time
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['date'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                item['time'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Reference Number
                        Expanded(
                          flex: 2,
                          child: Text(
                            item['reference'],
                            style: TextStyle(
                              fontSize: 14,
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
                              value: item['status'],
                              isExpanded: true,
                              isDense: true,
                              underline: Container(),
                              items: [
                                'For Delivery',
                                'Shipped',
                                'Cancelled',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  orderItems[index]['status'] = newValue;
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
                              // View order details
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
          Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () {},
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFCA2E55),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '1',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Text(' / 5'),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, int index) {
    bool isActive = _tabController.index == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.index = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Color(0xFFCA2E55) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4),
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Color(0xFFCA2E55),
                shape: BoxShape.circle,
              ),
              child: Text(
                '0',
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? Color(0xFFCA2E55) : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
