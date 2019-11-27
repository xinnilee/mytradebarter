import 'package:flutter/material.dart';
import 'package:mytradebarter/user.dart';
 
void main() => runApp(TabScreen3());
 
class TabScreen3 extends StatelessWidget {
  final User user;
  const TabScreen3({Key key, this.user}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: Center(
          child: Container(
            child: Text('Hello World'),
          ),
        ),
      ),
    );
  }
}