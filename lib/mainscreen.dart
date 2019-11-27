import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mytradebarter/tabscreen.dart';
import 'package:mytradebarter/tabscreen2.dart';
import 'package:mytradebarter/tabscreen3.dart';
import 'package:mytradebarter/tabscreen4.dart';
import 'package:mytradebarter/user.dart';

 
class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({Key key, this.user}) : super(key:key);

  @override
    _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Widget> tabs;
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    tabs = [
      TabScreen(user: widget.user),
      TabScreen2(user:widget.user),
      TabScreen3(user: widget.user),
      TabScreen4(user: widget.user),
    ];
  }

  String $pagetitle = "My Trade Barter";

  onTapped(int index) {
    setState(() {
      currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.blueGrey)
    );
    return Scaffold(
     body: tabs[currentTabIndex],
     bottomNavigationBar: BottomNavigationBar(
       onTap: onTapped,
       currentIndex: currentTabIndex,
       type: BottomNavigationBarType.fixed,

       items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text("Barter"),
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text("Posted Barter"),
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            title: Text("My Barter"),
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
          )
       ],
     ),
    );
  }
}
