import 'package:flutter/material.dart';

import '../main.dart';

class about_page extends StatelessWidget {
  const about_page({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "About Page Module",
      home: Scaffold(
        appBar: AppBar(
          title: Text('About Page Module'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [AboutPageBtnFieldSection()],
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

class AboutPageBtnFieldSection extends StatelessWidget {
  const AboutPageBtnFieldSection({super.key});

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
