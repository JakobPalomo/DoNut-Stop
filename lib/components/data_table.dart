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
  final Widget Function(Map<String, dynamic> row)?
      actionsBuilder; // Custom actions for each row

  const CustomDataTable({
    super.key,
    required this.data,
    required this.columns,
    this.rowsPerPage = 5,
    this.filters = const [],
    this.dropdowns = const [],
    this.actionsBuilder,
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

  double degreesToRadians(double degrees) {
    return degrees * (3.1415926535897932 / 180);
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
                  child: Row(children: [
                    ...widget.columns
                        .where((col) =>
                            col['type'] != 'actions') // Exclude actions column
                        .map<Widget>((col) {
                      return SizedBox(
                        width: col['width'], // Apply column width
                        child: Text(
                          col['label'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Inter',
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(width: 1),
                  ]),
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
                              .where((col) =>
                                  col['type'] !=
                                  'actions') // Exclude actions column
                              .map((col) {
                            final value = row[col['column']];
                            Widget content;

                            // Check if the column matches a dropdown configuration
                            final dropdownConfig = widget.dropdowns.firstWhere(
                              (dropdown) => dropdown['row'] == col['column'],
                              orElse: () => <String, dynamic>{},
                            );

                            if (dropdownConfig.isNotEmpty) {
                              // Render dropdown for the column
                              final options = dropdownConfig['options']
                                  as List<Map<String, dynamic>>;
                              content = DropdownButton2<String>(
                                value: value,
                                isExpanded: false,
                                items: options.map((option) {
                                  return DropdownMenuItem<String>(
                                    value: option['label'],
                                    child: Text(option['label']),
                                  );
                                }).toList(),
                                onChanged: (newVal) {
                                  if (newVal != null) {
                                    setState(() {
                                      row[col['column']] = newVal;
                                      _updateFilterCounts();
                                      _applyFilter();
                                    });
                                  }
                                },
                                underline: SizedBox(),
                                buttonStyleData: ButtonStyleData(
                                  height: 40,
                                  width: 120,
                                  padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border:
                                        Border.all(color: Color(0xFF767676)),
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 500,
                                  width: 120,
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
                              width: col['width'], // Apply column width
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
                      orElse: () =>
                          {'width': 130}, // Default width if not found
                    )['width'], // Get the width of the "actions" column
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
