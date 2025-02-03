import 'package:flutter/material.dart';

class products_page extends StatelessWidget{
  const products_page ({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Products Page Module",
      home: Scaffold(
        appBar: AppBar(
          title: Text('Products Page Module'),
        ),
      ),
    );
  }
}