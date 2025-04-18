import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itelec_quiz_one/components/pagination.dart';

class CustomDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<Map<String, dynamic>> columns;
  final int rowsPerPage;
  final List<Map<String, dynamic>> filters;

  const CustomDataTable({
    super.key,
    required this.data,
    required this.columns,
    this.rowsPerPage = 5,
    this.filters = const [],
  });

  @override
  State<CustomDataTable> createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  late List<Map<String, dynamic>> filteredData;
  int page = 1;
  int activeFilterValue = 0; // Default to "All"

  @override
  void initState() {
    super.initState();
    _updateFilterCounts();
    _applyFilter(); // Show all rows by default
  }

  void _updateFilterCounts() {
    // Update the count for each filter
    for (var filter in widget.filters) {
      if (filter['value'] == 0) {
        // "All" filter shows all rows
        filter['count'] = widget.data.length;
      } else {
        // Count rows matching the filter's value
        filter['count'] =
            widget.data.where((row) => row['role'] == filter['label']).length;
      }
    }
  }

  void _applyFilter() {
    setState(() {
      if (activeFilterValue == 0) {
        // Show all rows for "All" filter
        filteredData = List.from(widget.data);
      } else {
        // Filter rows based on the selected filter's value
        final selectedFilter = widget.filters
            .firstWhere((filter) => filter['value'] == activeFilterValue);
        filteredData = widget.data
            .where((row) => row['role'] == selectedFilter['label'])
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final startIndex = (page - 1) * widget.rowsPerPage;
    final endIndex =
        (startIndex + widget.rowsPerPage).clamp(0, filteredData.length);
    final currentPageData = filteredData.sublist(startIndex, endIndex);

    return Column(
      children: [
        // Filter Tabs
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Color(0xFFFFEEE1),
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
            child: ClipRect(
              child: Wrap(
                spacing: 0,
                runSpacing: 0,
                children: widget.filters.map((filter) {
                  return FilterButton(
                    filter: filter,
                    isActive: activeFilterValue == filter['value'],
                    onTap: () {
                      setState(() {
                        activeFilterValue = filter['value'];
                        _applyFilter();
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        // Table Header
        Container(
          color: const Color(0xFFDC345E),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: widget.columns.map((col) {
              return Expanded(
                child: Text(
                  col['label'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Table Rows
        Expanded(
          child: ListView.builder(
            itemCount: currentPageData.length,
            itemBuilder: (context, index) {
              final row = currentPageData[index];
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: widget.columns.map((col) {
                    return Expanded(
                      child: Text(row[col['column']].toString(),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.black,
                            fontSize: 13,
                          )),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),

        // Pagination
        Pagination(
          currentPage: page,
          totalPages: (filteredData.length / widget.rowsPerPage).ceil(),
          onPageChange: (int page) {
            setState(() {
              page = page; // Update the current page
            });
          },
        ),
      ],
    );
  }
}

class FilterButton extends StatelessWidget {
  final Map<String, dynamic> filter; // The filter data
  final bool isActive; // Whether the button is active
  final VoidCallback onTap; // Callback when the button is tapped

  const FilterButton({
    super.key,
    required this.filter,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String label = filter['label'];
    final int count = filter['count'];
    final Color color = filter['color'] ?? Colors.grey; // Default color
    final Color activeColor =
        filter['activeColor'] ?? Colors.blue; // Default active color

    return Material(
      color: isActive ? activeColor : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? color : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Color(0xFF462521),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  fontSize: 12,
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
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
    );
  }
}
