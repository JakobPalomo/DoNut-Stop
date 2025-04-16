import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int page) onPageChange;
  final TextEditingController _controller = TextEditingController();

  Pagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
  }) {
    _controller.text = currentPage.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Keep the controller in sync with the currentPage
    _controller.text = currentPage.toString();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                if (currentPage > 1) {
                  final newPage = currentPage - 1;
                  onPageChange(newPage);
                  _controller.text = newPage.toString();
                }
              },
            ),
            PageNumberField(
              controller: _controller,
              currentPage: currentPage,
              totalPages: totalPages,
              onPageChange: onPageChange,
            ),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                '/  $totalPages',
                style: TextStyle(
                  color: Colors.black,
                  height: 1,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: () {
                if (currentPage < totalPages) {
                  final newPage = currentPage + 1;
                  onPageChange(newPage);
                  _controller.text = newPage.toString();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PageNumberField extends StatefulWidget {
  final TextEditingController controller;
  final int currentPage;
  final int totalPages;
  final void Function(int page) onPageChange;

  const PageNumberField({
    super.key,
    required this.controller,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
  });

  @override
  State<PageNumberField> createState() => _PageNumberFieldState();
}

class _PageNumberFieldState extends State<PageNumberField> {
  final _focusNode = FocusNode();
  double fieldWidth = 30;
  bool showPopup = false;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      final length = widget.controller.text.length;
      setState(() {
        fieldWidth = (length * 20).clamp(30, 100).toDouble();
      });
    });

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _validateAndSubmit();
    });
  }

  void _validateAndSubmit() {
    final text = widget.controller.text;
    if (text.isEmpty || int.tryParse(text) == null) {
      widget.controller.text = '1';
      widget.onPageChange(1);
      return;
    }

    final value = int.parse(text);
    if (value < 1) {
      widget.controller.text = '1';
      widget.onPageChange(1);
    } else if (value > widget.totalPages) {
      setState(() {
        showPopup = true;
      });

      // Automatically hide the pop-up after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            showPopup = false;
          });
        }
      });

      widget.controller.text = widget.totalPages.toString();
      widget.onPageChange(widget.totalPages);
    } else {
      widget.onPageChange(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // TextField container
        Container(
          width: fieldWidth,
          height: 28,
          decoration: BoxDecoration(
            color: Color(0xFFCA2E55),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              height: 1,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              border: InputBorder.none,
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onFieldSubmitted: (_) => _validateAndSubmit(),
          ),
        ),
        // Pop-up container
        if (showPopup)
          Positioned(
            bottom: 40,
            left: -70,
            child: Center(
              child: Container(
                width: 200,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xFFFF7E9C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Should not exceed ${widget.totalPages}.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class PaginationSample extends StatefulWidget {
  @override
  _PaginationSampleState createState() => _PaginationSampleState();
}

class _PaginationSampleState extends State<PaginationSample> {
  int currentPage = 1; // Initial page
  final int totalPages = 5; // Total number of pages

  void _handlePageChange(int newPage) {
    setState(() {
      currentPage = newPage; // Update the current page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pagination Example")),
      body: Center(
        child: Pagination(
          currentPage: currentPage, // Pass the current page
          totalPages: totalPages, // Pass the total pages
          onPageChange: _handlePageChange, // Handle page changes
        ),
      ),
    );
  }
}
