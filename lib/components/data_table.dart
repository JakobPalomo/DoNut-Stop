import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itelec_quiz_one/components/pagination.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<Map<String, dynamic>> columns;
  final int rowsPerPage;
  final List<Map<String, dynamic>> filters;
  final List<Map<String, dynamic>> dropdowns;
  final String searchQuery;
  final Widget Function(Map<String, dynamic> row)? actionsBuilder;
  final void Function(Map<String, dynamic> row, int newRole)?
      onRoleChanged; // New callback

  const CustomDataTable({
    super.key,
    required this.data,
    required this.columns,
    this.rowsPerPage = 5,
    this.filters = const [],
    this.dropdowns = const [],
    this.searchQuery = '',
    this.actionsBuilder,
    this.onRoleChanged, // Accept the callback
  });

  @override
  State<CustomDataTable> createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  late List<Map<String, dynamic>> filteredData;
  int page = 1;
  int activeFilterValue = 0; // Default to "All"
  late List<Map<String, dynamic>> sortedData;
  String? sortedColumn;
  bool ascending = true;

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
        final column = widget.dropdowns[0]['row'];
        filter['count'] =
            widget.data.where((row) => row[column] == filter['value']).length;
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
        final column = widget.dropdowns[0]['row'];
        filteredData = widget.data
            .where((row) => row[column] == selectedFilter['value'])
            .toList();
      }

      // Apply search query
      if (widget.searchQuery.isNotEmpty) {
        filteredData = filteredData
            .where((row) => row.values.any((value) => value
                .toString()
                .toLowerCase()
                .contains(widget.searchQuery.toLowerCase())))
            .toList();
      }

      // Apply sorting to the filtered data
      if (sortedColumn != null) {
        filteredData.sort((a, b) {
          final aValue = a[sortedColumn!];
          final bValue = b[sortedColumn!];

          int comparison;
          switch (widget.columns
              .firstWhere((col) => col['column'] == sortedColumn)['type']) {
            case 'number':
              comparison = (aValue as num).compareTo(bValue as num);
              break;
            case 'date':
              comparison =
                  DateTime.parse(aValue).compareTo(DateTime.parse(bValue));
              break;
            default:
              comparison = aValue.toString().compareTo(bValue.toString());
          }

          return ascending ? comparison : -comparison;
        });
      }
    });
  }

  void _sortData(String column, String type) {
    setState(() {
      if (sortedColumn == column) {
        ascending = !ascending;
      } else {
        sortedColumn = column;
        ascending = true;
      }

      // Reset to the first page
      page = 1;

      // Reapply filter and sorting
      _applyFilter();
    });
  }

  double degreesToRadians(double degrees) {
    return degrees * (3.1415926535897932 / 180);
  }

  @override
  Widget build(BuildContext context) {
    _applyFilter();

    final startIndex = (page - 1) * widget.rowsPerPage;
    final endIndex =
        (startIndex + widget.rowsPerPage).clamp(0, filteredData.length);
    final currentPageData = filteredData.sublist(startIndex, endIndex);

    return Column(
      children: [
        // Filter Tabs
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color(0xFFFFEEE1),
            border: Border.all(
              color: Color(0xFFD0B8A4),
              width: 1,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
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
                        page = 1;
                        _applyFilter();
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),

        // Table Header
        Row(
          children: [
            // Scrollable Header
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  color: const Color(0xFFDC345E),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      ...widget.columns
                          .where((col) =>
                              col['type'] !=
                              'actions') // Exclude actions column
                          .map((col) {
                        return InkWell(
                          onTap: col['sortable']
                              ? () => _sortData(col['column'], col['type'])
                              : null,
                          child: SizedBox(
                            width: col['width'], // Apply column width
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  col['label'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                if (sortedColumn == col['column'])
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Icon(
                                      ascending
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed Actions Header
            SizedBox(
              width: widget.columns.firstWhere(
                (col) => col['type'] == 'actions',
                orElse: () => {'width': 100}, // Default width if not found
              )['width'], // Fixed width for actions column
              child: Container(
                color: const Color(0xFFDC345E),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: const Text(
                  '', // Blank header for actions
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ],
        ),

        // Table Rows
        Expanded(
          child: ListView.builder(
            itemCount: currentPageData.length,
            itemBuilder: (context, index) {
              final row = currentPageData[index];
              return Row(
                children: [
                  // Scrollable Row Content
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Row(children: [
                          ...widget.columns
                              .where((col) => col['type'] != 'actions')
                              .map((col) {
                            final value = row[col['column']];
                            Widget content;

                            // Check if the column matches a dropdown configuration
                            final dropdownConfig = widget.dropdowns.firstWhere(
                              (dropdown) => dropdown['row'] == col['column'],
                              orElse: () => <String,
                                  Object>{}, // Ensure the default type matches
                            );

                            if (dropdownConfig.isNotEmpty) {
                              // Render dropdown for the column
                              final options = dropdownConfig['options']
                                  as List<Map<String, Object>>;
                              final selectedOption = options.firstWhere(
                                (option) => option['value'] == value,
                                orElse: () => {'label': 'Unknown', 'value': ''},
                              );

                              content = DropdownButton2<int>(
                                value: value
                                    as int?, // Ensure the value is cast to int
                                isExpanded: false,
                                items: options.map((option) {
                                  return DropdownMenuItem<int>(
                                    value: option['value']
                                        as int, // Ensure the value is an int
                                    child: Text(option['label'] as String),
                                  );
                                }).toList(),
                                onChanged: (newVal) {
                                  if (newVal != null) {
                                    setState(() {
                                      row[col['column']] =
                                          newVal; // Update the local value
                                      _updateFilterCounts();
                                      _applyFilter();
                                    });

                                    // Trigger the onRoleChanged callback to update the database
                                    if (widget.onRoleChanged != null) {
                                      widget.onRoleChanged!(row, newVal);
                                    }
                                  }
                                },
                                underline: SizedBox(),
                                buttonStyleData: ButtonStyleData(
                                  height: 40,
                                  width: col['width'] - 20 ?? 120,
                                  padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border:
                                        Border.all(color: Color(0xFF767676)),
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 500,
                                  width: col['width'] - 20 ?? 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.all(0),
                                ),
                                menuItemStyleData: MenuItemStyleData(
                                  height: 40,
                                  padding: EdgeInsets.only(left: 10),
                                ),
                                iconStyleData: IconStyleData(
                                  icon: Transform.rotate(
                                    angle: degreesToRadians(90),
                                    child: Icon(Icons.chevron_right),
                                  ),
                                ),
                              );
                            } else if (col['type'] == 'date') {
                              // Format date column
                              final date = DateTime.tryParse(value);
                              content = Text(
                                date != null
                                    ? DateFormat('yMMMd').add_jm().format(date)
                                    : value.toString(),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              );
                            } else {
                              // Default text content
                              content = Text(
                                value.toString(),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              );
                            }

                            return SizedBox(
                              width: col['width'],
                              child: content,
                            );
                          }).toList(),
                          SizedBox(width: 1),
                        ]),
                      ),
                    ),
                  ),

                  // Fixed Actions Column
                  SizedBox(
                    width: widget.columns.firstWhere(
                      (col) => col['type'] == 'actions',
                      orElse: () => {'width': 130},
                    )['width'],
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: widget.actionsBuilder != null
                          ? widget.actionsBuilder!(row)
                          : const SizedBox(),
                    ),
                  ),
                ],
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
              this.page = page; // Update the current page
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
                  fontSize: 14,
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
