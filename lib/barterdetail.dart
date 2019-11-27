import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mytradebarter/user.dart';
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'barter.dart';
import 'mainscreen.dart';
 

class BarterDetail extends StatefulWidget {
  final Barter barter;
  final User user;

  const BarterDetail({Key key, this.barter, this.user}) : super(key: key);

  @override
  _BarterDetailState createState() => _BarterDetailState();
}

class _BarterDetailState extends State<BarterDetail> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.blueGrey)
    );
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('BARTER DETAILS'),
          backgroundColor: Colors.blueGrey,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
            child: DetailInterface(
              barter: widget.barter,
              user: widget.user,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressAppBar() async {
    Navigator.pop(
      context, 
      MaterialPageRoute(
        builder: (context) => MainScreen(user: widget.user),
      )
    );
    return Future.value(false);
  }
}

class DetailInterface extends StatefulWidget {
  final Barter barter;
  final User user;
  DetailInterface({this.barter, this.user});

  @override
  _DetailInterfaceState createState() => _DetailInterfaceState();
}

class _DetailInterfaceState extends State<DetailInterface> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _myLocation;
  
  @override
  void initState() {
    super.initState();
    _myLocation = CameraPosition(
      target: LatLng(
        double.parse(
          widget.barter.barterlat
        ),
        double.parse(
          widget.barter.barterlon
        )
      ),
      zoom: 17,
    );
    print(_myLocation.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(),
        Container(
          width: 280,
          height: 200,
          child: Image.network(
            'http://tradebarterflutter.com/mytradebarter/images/${widget.barter.barterimage}', 
            fit: BoxFit.fill,
          ),
        ),

        SizedBox(height: 10,),

        Text(
          widget.barter.bartertitle.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )
        ),

        Text(widget.barter.bartertime),

        Container(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 5,),
              Table(children:[
                TableRow(children: [
                  Text(
                    "Barter Description",
                    style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  Text(widget.barter.barterdes),
                ]),

                TableRow(children: [
                  Text(
                    "Barter Price",
                    style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  Text("RM" + widget.barter.barterprice),
                ]),

                TableRow(children: [
                  Text(
                    "Barter Location",
                    style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  Text(""),
                ]),
              ]),

              SizedBox(height: 10,),

              Container(
                height: 120,
                width: 340,
                child: GoogleMap(
                  initialCameraPosition: _myLocation,
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller){
                    _controller.complete(controller);
                  },
                ),
              ),
              
              SizedBox(height: 10,),

              Container(
                width: 350,
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)
                  ),
                  height: 40,
                  child: Text(
                    "ACCEPT BARTER",
                    style: TextStyle(fontSize: 16),
                  ),
                  color: Colors.blueAccent,
                  textColor: Colors.white,
                  elevation: 5,
                  onPressed: _onAcceptBarter,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  void _onAcceptBarter() {
    if(widget.user.email=="user@nonregister") {
      Toast.show(
        "Please register to view accept barter",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM
      );
      return;
    } else {
      _showDialog();
    }
    print("Accept Barter");
  }

  void _showDialog() {
    if(int.parse(widget.user.credit) < 1) {
      Toast.show(
        "Credit not enough", 
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM);
        return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Accept " + widget.barter.bartertitle),
          content: new Text("Are you sure?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                acceptRequest();
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

  Future<String> acceptRequest() async {
    String urlAcceptBarter = "http://tradebarterflutter.com/mytradebarter/php/accept_barter.php";
    ProgressDialog pr = new ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false
    );
    pr.style(message: "Accepting Barter");
    pr.show();

    http.post(urlAcceptBarter, body: {
      "barterid": widget.barter.barterid,
      "email": widget.user.email,
      "credit": widget.user.credit,
    }).then((res) {
      print(res.body);

      if(res.body == "success") {
        Toast.show(
          "Success", 
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM
        );
        pr.dismiss();
        _onLogin(widget.user.email, context);
      } else {
        Toast.show(
          "Failed",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM
        );
      }
    }).catchError((err) {
      print(err);
      pr.dismiss();
    });
    return null;
  }

  void _onLogin(String email, BuildContext ctx) {
    String urlgetuser = "";

    http.post(urlgetuser, body: {
      "email": email,
    }).then((res) {
      print(res.statusCode);
      var string = res.body;
      List dres = string.split(",");
      print(dres);

      if(dres[0] == "success") {
        User user = new User(
          name: dres[1],
          email: dres[2],
          phone: dres[3],
          radius: dres[4],
          credit: dres[5],
          rating: dres[6]
        );
        Navigator.push(
          ctx, 
          MaterialPageRoute(builder: (context) => MainScreen(user: user))
        );
      }
    }).catchError((err) {
      print(err);
    });
  }
}