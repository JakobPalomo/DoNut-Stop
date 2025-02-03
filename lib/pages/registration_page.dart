import 'package:flutter/material.dart';
import '../main.dart';

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
        body: SingleChildScrollView(
          child: Column(
            children: [
              ImgSection(),
              TxtFieldSection(),
              BtnFieldSection(),
            ],
          ),

        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrwerHeader(),
              DrwListView()
            ],
          ),
        ),
      ),
    );
  }
}

class TxtFieldSection extends StatelessWidget {
  const TxtFieldSection ({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment:  CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "This is a hint",
                    hintMaxLines: 2, hintStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)

                ),
              )
              ),
              Expanded(child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Another part",
                    hintMaxLines: 2,
                    hintStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
                ),
              ))
            ],
          ),
          Padding(padding: EdgeInsets.all(30),
            child: TextField(
              decoration:  InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Address",
                  hintMaxLines: 2,
                  hintStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)

              ),
            ),
          ),
          Padding(padding: EdgeInsets.all(30),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Work Address",
                  hintMaxLines: 2,
                  hintStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)

              ),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Mobile No",
                    hintMaxLines: 2,
                    hintStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)

                ),
              )
              ),
              Expanded(child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Mobile No",
                    hintMaxLines: 2,
                    hintStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)

                ),
              )
              )
            ],)

        ],

      ),
    );
  }
}

class BtnFieldSection extends StatelessWidget{
  const BtnFieldSection ({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(30),
      child:
      Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: ElevatedButton(onPressed: null, child: Text("Disabled"))),
          Expanded(child: ElevatedButton(onPressed: () {}, child: Text("Enabled"))),
          Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: Icon(Icons.add, color: Colors.black), label: Text("Enabled with icon")))
        ],
      ),);
  }
}

class ImgSection extends StatelessWidget{
  const ImgSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(30),
        child:
        Container(
          height: 150.0,
          width: double. maxFinite,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/test.jpg'),
                  fit: BoxFit.fill
              )
          ),
        )
    );
  }

}