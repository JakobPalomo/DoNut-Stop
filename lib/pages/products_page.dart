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
        body: SingleChildScrollView(
          child: Column(
            children: [
              ProductPageBtnFieldSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductPageBtnFieldSection extends StatelessWidget{
  const ProductPageBtnFieldSection ({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(30),
      child:
      Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => products_page())) , icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black), label: Text("Back Home")))
        ],
      ),);
  }
}
