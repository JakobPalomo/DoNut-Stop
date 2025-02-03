import 'package:flutter/material.dart';

class home_page extends StatelessWidget{
  const home_page ({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Home Page Module",
      home: Scaffold(
        appBar: AppBar(
          title: Text('Home Page Module'),
        ),
      ),
    );
  }
}