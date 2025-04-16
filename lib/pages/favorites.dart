import 'package:flutter/material.dart';
import 'package:itelec_quiz_one/components/user_drawers.dart';

class MyFavoritesPage extends StatefulWidget {
  const MyFavoritesPage({super.key});

  @override
  State<MyFavoritesPage> createState() => _MyFavoritesPageState();
}

class _MyFavoritesPageState extends State<MyFavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My Favorites",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFE0B6),
      ),
      home: Scaffold(
          appBar: AppBarWithMenuAndTitle(title: "My Favorites"),
          drawer: UserDrawer(),
          body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: []))),
    );
  }
}
