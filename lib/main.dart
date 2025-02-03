import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/pages/about_page.dart';
import 'package:itelec_quiz_one/pages/free_page.dart';
import 'package:itelec_quiz_one/pages/home_page.dart';
import 'package:itelec_quiz_one/pages/products_page.dart';
import 'package:itelec_quiz_one/pages/registration_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: "ITELEC4C",
      home: Scaffold(
        appBar: AppBar(
          title: Text("ITELEC4C"),

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

class DrwerHeader extends StatefulWidget{
  @override
  _Drwheader createState() => _Drwheader();
}

class _Drwheader extends State<DrwerHeader>{
  @override
  Widget build (BuildContext context){
    return DrawerHeader(
      decoration:BoxDecoration(
          color: Colors.black54
      ),

      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/test.jpg'),
            radius: 40,
          ),
          SizedBox(height: 20),
          Text(
            "ITELEC4C",
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold
            ),

          )
        ],
      ),
    );
  }
}

class DrwListView extends StatefulWidget{
  @override
  _DrwListView createState() => _DrwListView();
}
class _DrwListView extends State<DrwListView>{
  @override

  Widget build(BuildContext context){
    return Padding(padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            title: Text("Registration"),
            leading: Icon(Icons.add_box_sharp),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => registration_page())) ,
          ),
          ListTile(
            title: Text("Home"),
            leading: Icon(Icons.add_box_sharp),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => home_page())) ,
          ),
          ListTile(
            title: Text("About"),
            leading: Icon(Icons.add_box_sharp),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => about_page())) ,
          ),
          ListTile(
            title: Text("Products"),
            leading: Icon(Icons.add_box_sharp),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => products_page())) ,
          ),
          ListTile(
            title: Text("Contact"),
            leading: Icon(Icons.add_box_sharp),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => free_page())) ,
          ),

        ],
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