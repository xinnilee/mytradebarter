import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mytradebarter/newbarter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:mytradebarter/registrationscreen.dart';
import 'package:mytradebarter/user.dart';
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart'; 

double perpage = 1;

class TabScreen2 extends StatefulWidget {
  final User user;
  TabScreen2({Key key, this.user});

  @override
  _TabScreen2State createState() => _TabScreen2State();
}

class _TabScreen2State extends State<TabScreen2> {
  GlobalKey<RefreshIndicatorState> refreshKey;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress = "Searching current location...";
  List data;

  @override
  void initState(){
    super.initState();
    refreshKey = GlobalKey<RefreshIndicatorState>();
    //_getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.blueGrey)
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.blueGrey,
          elevation: 2.0,
          onPressed: (){},
          tooltip: 'Request new help',
        ),

        body: RefreshIndicator(
          key: refreshKey,
          color: Colors.blueGrey,
          onRefresh: () async {
            await refreshList();
          },
          child: ListView.builder(
            itemCount: data == null ? 1 : data.length + 1,
            itemBuilder: (context, index) {
              if(index == 0) {
                return Container(
                  child: Column(
                    children: <Widget>[
                      Stack(children: <Widget>[
                        Image.asset(
                          "assets/images/background.png",
                          fit: BoxFit.fitWidth,
                          height: 210,
                          width: 500,
                        ),
                        Column(
                          children: <Widget>[SizedBox(height: 20,),
                          Center(
                            child: Text(
                              "MyTradeBarter",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                              )
                            ),
                          ),
                          SizedBox(height: 10,),

                          Container(
                            width: 300,
                            height: 140,
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.person),
                                        SizedBox(width: 5,),
                                        Flexible(
                                          child: Text(
                                            widget.user.name.toUpperCase() ?? "Not registered",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.location_on),
                                        SizedBox(width: 5,),
                                        Flexible(
                                          child: Text(_currentAddress),
                                        ),
                                      ],
                                    ),                                      

                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.rounded_corner),
                                        SizedBox(width: 5,),
                                        Flexible(
                                          child: Text(
                                            "Barter radius within " +
                                            widget.user.radius +
                                            " KM"
                                          ),
                                        ),
                                      ],
                                    ),  

                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.credit_card),
                                        SizedBox(width: 5,),
                                        Flexible(
                                          child: Text(
                                            "You have " +
                                            widget.user.credit +
                                            " Credit"
                                          ),
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          )
                          ],
                        )
                      ],),

                      SizedBox(height: 4,),
                      Container(
                        color: Colors.blueGrey,
                        child: Center(
                          child: Text(
                            "Your Posted Barter ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if(index == data.length && perpage > 1) {
                return Container(
                  width: 250,
                  color: Colors.white,
                  child: MaterialButton(
                    child: Text(
                      "Load More",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {},
                  ),
                );
              }

              index -= -1;
              return Padding(
                padding: EdgeInsets.all(2.0),
                child: Card(
                  elevation: 2,
                  child: InkWell(
                    onLongPress: () => _onBarterDelete(
                      data[index]['barterid'].toString(),
                      data[index]['bartertitle'].toString()
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white),
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(
                                  ""
                                )
                              )
                            )
                          ),

                          Expanded(
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    data[index]['bartertitle']
                                    .toString()
                                    .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold
                                    )
                                  ),

                                  RatingBar(
                                    itemCount: 5,
                                    itemSize: 12,
                                    initialRating: double.parse(
                                      data[index]['barterrating']
                                      .toString()
                                    ),
                                    itemPadding: EdgeInsets.symmetric(
                                      horizontal: 2.0
                                    ),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),onRatingUpdate: (double value) {},
                                  ),

                                  SizedBox(height: 5,),
                                  Text("RM "+data[index]['barterprice']),
                                  SizedBox(height: 5,),
                                  Text(data[index]['bartertime']),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        )
      )
    );
  }

    _getCurrentLocation() async {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        print(_currentPosition);
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name},${place.locality}, ${place.postalCode}, ${place.country}";
        init(); //load data from database into list array 'data'
      });
    } catch (e) {
      print(e);
    }
  }  

  Future<String> makeRequest() async {
    String urlLoadJobs = "http://tradebarterflutter.com/mytradebarter/php/load_barter_user.php";
     ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
        pr.style(message: "Loading All Accepted Barter");
    pr.show();
    http.post(urlLoadJobs, body: {
      "email": widget.user.email ?? "notavail",

    }).then((res) {
      setState(() {
        var extractdata = json.decode(res.body);
        data = extractdata["barter"];
        perpage = (data.length / 10);
        print("data");
        print(data);
        pr.dismiss();
      });
    }).catchError((err) {
      print(err);
      pr.dismiss();
    });
    return null;
  }

  Future init() async {
    if (widget.user.email=="user@noregister"){
      Toast.show("Please register to view posted barter", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }else{
      this.makeRequest();
    }
  }  

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    this.makeRequest();
    return null;
  }

  void requestNewBarter() {
    print(widget.user.email);
    if (widget.user.email != "user@noregister") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => NewBarter(
                    user: widget.user,
                  )));
    } else {
      Toast.show("Please Register First to request new barter", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => RegisterScreen()));
    }
  }

  void _onBarterDelete(String barterid, String bartername) {
    print("Delete " + barterid);
    _showDialog(barterid, bartername);
  }    

  void _showDialog(String barterid, String bartername) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Delete " + bartername),
          content: new Text("Are your sure?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                deleteRequest(barterid);
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }  

  Future<String> deleteRequest(String barterid) async {
    String urlLoadJobs = "http://tradebarterflutter.com/mytradebarter/php/delete_barter.php";
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Deleting Barter");
    pr.show();
    http.post(urlLoadJobs, body: {
      "barterid": barterid,
    }).then((res) {
      print(res.body);
      if (res.body == "success") {
        Toast.show("Success", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        init();
      } else {
        Toast.show("Failed", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }).catchError((err) {
      print(err);
      pr.dismiss();
    });
    return null;
  }
}
class SlideMenu extends StatefulWidget {
  final Widget child;
  final List<Widget> menuItems;

  SlideMenu({this.child, this.menuItems});

  @override
  _SlideMenuState createState() => new _SlideMenuState();
}

class _SlideMenuState extends State<SlideMenu> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  initState() {
    super.initState();
    _controller = new AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = new Tween(
      begin: const Offset(0.0, 0.0),
      end: const Offset(-0.2, 0.0)
    ).animate(new CurveTween(curve: Curves.decelerate).animate(_controller));

    return new GestureDetector(
      onHorizontalDragUpdate: (data) {
        // we can access context.size here
        setState(() {
          _controller.value -= data.primaryDelta / context.size.width;
        });
      },
      onHorizontalDragEnd: (data) {
        if (data.primaryVelocity > 2500)
          _controller.animateTo(.0); 
        else if (_controller.value >= .5 || data.primaryVelocity < -2500) 
          _controller.animateTo(1.0);
        else 
          _controller.animateTo(.0);
      },
      child: new Stack(
        children: <Widget>[
          new SlideTransition(position: animation, child: widget.child),
          new Positioned.fill(
            child: new LayoutBuilder(
              builder: (context, constraint) {
                return new AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return new Stack(
                      children: <Widget>[
                        new Positioned(
                          right: .0,
                          top: .0,
                          bottom: .0,
                          width: constraint.maxWidth * animation.value.dx * -1,
                          child: new Container(
                            color: Colors.black26,
                            child: new Row(
                              children: widget.menuItems.map((child) {
                                return new Expanded(
                                  child: child,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }  
  
}