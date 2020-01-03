import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mytradebarter/user.dart';
import 'barter.dart';
import 'mainscreen.dart';
 

class Detail extends StatefulWidget {
  final Barter barter;
  final User user;

  const Detail({Key key, this.barter, this.user}) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
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
        SizedBox(height: 20,),

        Container(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10,),
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
              
              SizedBox(height: 20,),

            ],
          ),
        )
      ],
    );
  }

}