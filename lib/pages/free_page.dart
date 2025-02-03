import 'package:flutter/material.dart';

class free_page extends StatelessWidget{
  const free_page ({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Free Page Module",
      home: Scaffold(
        appBar: AppBar(
          title: Text('Free Page Module'),
        ),
      ),
    );
  }
}