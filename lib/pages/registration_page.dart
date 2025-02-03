import 'package:flutter/material.dart';

class registration_page extends StatelessWidget{
  const registration_page({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Registration Page Module",
      home: Scaffold(
        appBar: AppBar(
          title: Text('Registration Page Module'),
        ),
      ),
    );
  }
}