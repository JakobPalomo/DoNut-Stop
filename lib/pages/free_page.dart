import 'package:flutter/material.dart';

import '../main.dart';

class free_page extends StatelessWidget {
  const free_page({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Free Page Module",
      home: Scaffold(
        appBar: AppBar(
          title: Text('Free Page Module'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [ContactPageBtnFieldSection()],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: [DrwerHeader(), DrwListView()],
          ),
        ),
      ),
    );
  }
}

class ContactPageBtnFieldSection extends StatelessWidget {
  const ContactPageBtnFieldSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyApp())),
                  icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
                  label: Text("Back Home")))
        ],
      ),
    );
  }
}
