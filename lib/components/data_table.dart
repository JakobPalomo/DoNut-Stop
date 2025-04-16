import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itelec_quiz_one/components/pagination.dart';

class CustomDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<Map<String, dynamic>> columns;
  final int rowsPerPage;
  final int page;

  const CustomDataTable({
    super.key,
    required this.data,
    required this.columns,
    this.rowsPerPage = 5,
    this.page = 1,
  });

  @override
  State<CustomDataTable> createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  late int currentPage;
  late List<Map<String, dynamic>> sortedData;
  String? sortedColumn;
  bool ascending = true;

  @override
  void initState() {
    super.initState();
    currentPage = widget.page;
    sortedData = List.from(widget.data);
  }

  void _sortData(String column, String type) {
    setState(() {
      if (sortedColumn == column) {
        ascending = !ascending;
      } else {
        sortedColumn = column;
        ascending = true;
      }

      sortedData.sort((a, b) {
        final aValue = a[column];
        final bValue = b[column];

        int comparison;
        switch (type) {
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

      currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final startIndex = (currentPage - 1) * widget.rowsPerPage;
    final endIndex =
        (startIndex + widget.rowsPerPage).clamp(0, sortedData.length);
    final currentPageData = sortedData.sublist(startIndex, endIndex);
    final totalPages = (sortedData.length / widget.rowsPerPage).ceil();

    return Column(
      children: [
        Container(
          color: const Color(0xFFDC345E),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              ...widget.columns.map((col) {
                return Expanded(
                  child: InkWell(
                    onTap: col['sortable']
                        ? () => _sortData(col['column'], col['type'])
                        : null,
                    child: Row(
                      children: [
                        Text(
                          col['label'],
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (sortedColumn == col['column'])
                          Icon(
                            ascending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                            color: Colors.white,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const Expanded(child: SizedBox()), // For actions
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: currentPageData.length,
            itemBuilder: (context, index) {
              final user = currentPageData[index];
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    ...widget.columns.map((col) {
                      final value = user[col['column']];
                      Widget content;

                      if (col['column'] == 'role') {
                        content = Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButton<String>(
                            value: value,
                            isExpanded: true,
                            isDense: true,
                            underline: const SizedBox(),
                            items: [
                              'Customer',
                              'Employee',
                              'Admin',
                            ].map((String val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(val),
                              );
                            }).toList(),
                            onChanged: (newVal) {
                              setState(() {
                                user[col['column']] = newVal;
                              });
                            },
                          ),
                        );
                      } else if (col['type'] == 'date') {
                        final date = DateTime.tryParse(value);
                        content = Text(
                          date != null
                              ? DateFormat('yMMMd').add_jm().format(date)
                              : value.toString(),
                        );
                      } else {
                        content = Text(value.toString());
                      }

                      return Expanded(child: content);
                    }).toList(),

                    // Actions
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility,
                                color: Color(0xFFCA2E55)),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Color(0xFFCA2E55)),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Color(0xFFCA2E55)),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
        Pagination(
          currentPage: currentPage,
          totalPages: totalPages,
          onPageChange: (int page) {
            setState(() {
              currentPage = page; // Update the current page
            });
          },
        ),
      ],
    );
  }
}
