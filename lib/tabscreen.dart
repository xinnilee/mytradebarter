import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:mytradebarter/barter.dart';
import 'package:mytradebarter/barterdetail.dart';
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mytradebarter/user.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'SlideRightRoute.dart';

double perpage = 1;

class TabScreen extends StatefulWidget {
  final User user;
  TabScreen({Key key, this.user});

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  GlobalKey<RefreshIndicatorState> refreshKey;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress = "Searching current location...";
  List data;

  @override
  void initState(){
    super.initState();
    refreshKey = GlobalKey<RefreshIndicatorState>();
    _getCurrentLocation();
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
                        Container(
                        child: Image.asset(
                          "assets/images/background.png",
                          fit: BoxFit.fitWidth,
                          height: 210,
                          width: 500,
                        ),
                        ),

                        Column(
                          children: <Widget>[
                            SizedBox(height: 20,),

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
                                              widget.user.name.toUpperCase() ??
                                              "Not registered",
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
                                          Flexible(child: Text(_currentAddress),),
                                        ],
                                      ),

                                      Row(
                                        children: <Widget>[
                                          Icon(Icons.rounded_corner),
                                          SizedBox(width: 5,),
                                          Flexible(
                                            child: Text(
                                              "Barter Radius within " + widget.user.radius + " KM"
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
                                              "You have " + widget.user.credit + " Credit"
                                            ),
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],),

                      SizedBox(height: 4,),

                      Container(
                        color: Colors.blueGrey,
                        child: Center(
                          child: Text(
                            "Barter Available Today",
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

              index -= 1;
              return Padding(
                padding: EdgeInsets.all(2.0),
                child: Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () => _onBarterDetail(
                      data[index]['barterid'],
                      data[index]['barterprice'],
                      data[index]['barterdesc'],
                      data[index]['barterowner'],
                      data[index]['barterimage'],
                      data[index]['bartertime'],
                      data[index]['bartertitle'],
                      data[index]['barterlatitude'],
                      data[index]['barterlongitude'],
                      data[index]['barterrating'],
                      widget.user.radius,
                      widget.user.name,
                      widget.user.credit,
                    ),

                    onLongPress: _onBarterDelete,

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
                                image: NetworkImage("http://tradebarterflutter.com/mytradebarter/images/${data[index]['barterimage']}")
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
                                    
                                    itemCount : 5,
                                    itemSize : 12,
                                    initialRating : double.parse(data[index]['barterrating']
                                      .toString()),
                                      itemPadding : EdgeInsets.symmetric(
                                        horizontal: 2.0
                                      ),
                                      itemBuilder : (context, _) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ), onRatingUpdate: (double value) {},
                                  ),

                                  SizedBox(height: 5,),

                                  Text("RM " + data[index]['barterprice']),

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

            }
          ),
        )
      )
    );
  }

  _getCurrentLocation () async {
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
        _currentPosition.latitude, _currentPosition.longitude
      );

      Placemark place = p[0];

      setState(() {
        _currentAddress = 
          "${place.name},${place.locality},${place.postalCode},${place.country}";
          init();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<String> makeRequest() async {
    String urlLoadBarter = "http://tradebarterflutter.com/mytradebarter/php/load_barter.php";
    ProgressDialog pr = new ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false
    );
    pr.style(message: "Loading Barter");
    pr.show();
    http.post(urlLoadBarter, body: {
      "email": widget.user.email ?? "notavail",
      "latitude": _currentPosition.latitude.toString(),
      "longitude": _currentPosition.longitude.toString(),
      "radius": widget.user.radius ?? "10",
    }).then((res) {
      setState(() {
        print("acasd");
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
    this.makeRequest();
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    this.makeRequest();
    return null;
  }

  void _onBarterDetail(
    String barterid,
    String barterprice,
    String barterdesc,
    String barterowner,
    String barterimage,
    String bartertime,
    String bartertitle,
    String barterlatitude,
    String barterlongtitude,
    String barterrating,
    String email,
    String name,
    String credit
  ) {
    Barter barter = new Barter(
      barterid : barterid,
      barterprice : barterprice,
      barterdes : barterdesc,
      barterowner : barterowner,
      barterimage : barterimage,
      bartertime : bartertime,
      bartertitle : bartertitle,
      barterworker : null,
      barterlat : barterlatitude,
      barterlon : barterlongtitude,
      barterrating : barterrating,
    );
    print(data);

    Navigator.push(
      context, 
      SlideRightRoute(page: BarterDetail(barter: barter, user: widget.user))
    );
  }

  void _onBarterDelete() {
    print("Delete");
  }
}