import 'package:flutter/material.dart';

class about_page extends StatelessWidget{
  const about_page ({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "About Page Module",
      home: Scaffold(
        appBar: AppBar(
          title: Text('About Page Module'),
        ),
      ),
    );
  }
}