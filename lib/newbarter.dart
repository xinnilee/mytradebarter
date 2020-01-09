import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mytradebarter/mainscreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mytradebarter/user.dart';
import 'package:toast/toast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:place_picker/place_picker.dart';

File _image;
String pathAsset = 'assets/images/background.png';
String urlUpload = "http://tradebarterflutter.com/mytradebarter/php/upload_barter.php";
String urlgetuser = "http://tradebarterflutter.com/mytradebarter/php/get_user.php";

TextEditingController _bartercontroller = TextEditingController();
final TextEditingController _desccontroller = TextEditingController();
final TextEditingController _pricecontroller = TextEditingController();
final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
Position _currentPosition;
String _currentAddress = "Searching your current location...";

class NewBarter extends StatefulWidget {
  final User user;

  const NewBarter({Key key, this.user}) : super(key: key);

  @override
  _NewBarterState createState() => _NewBarterState();
}

class _NewBarterState extends State<NewBarter> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
          appBar: AppBar(
            title: Text('REQUEST NEW BARTER'),
            backgroundColor: Colors.blueGrey,
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
              child: CreateNewBarter(widget.user),
            ),
          )),
    );
  }

  Future<bool> _onBackPressAppBar() async {
    Navigator.pop(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(
            user: widget.user,
          ),
        ));
    return Future.value(false);
  }
}

class CreateNewBarter extends StatefulWidget {
  final User user;
  CreateNewBarter(this.user);

  @override
  _CreateNewBarterState createState() => _CreateNewBarterState();
}

class _CreateNewBarterState extends State<CreateNewBarter> {
  String defaultValue = 'Pickup';
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
            onTap: _choose,
            child: Container(
              width: 350,
              height: 200,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image:
                    _image == null ? AssetImage(pathAsset) : FileImage(_image),
                fit: BoxFit.fill,
              )),
            )),

        Text('Click on image above to take barter picture',),

        TextField(
          controller: _bartercontroller,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Barter Title',
            icon: Icon(Icons.title),
        )),
          
        TextField(
          controller: _pricecontroller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Barter Price',
            icon: Icon(Icons.attach_money),
        )),
        
        TextField(
          controller: _desccontroller,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Barter Description',
            icon: Icon(Icons.info),
        )),
        
        SizedBox(height: 20,),
                                                 
        GestureDetector(
          onTap: _loadmap,
          child: Container(
            alignment: Alignment.topLeft,
            child: Text("Barter Location",
            style: TextStyle(fontWeight: FontWeight.bold)),
          )),
                                                 
        SizedBox( height: 10,),
                                                 
        Row(
          children: <Widget>[
            Icon(Icons.location_searching),
            SizedBox(width: 10, ),
            Flexible(
              child: Text(_currentAddress),
            )
          ],
        ),

        SizedBox(height: 20,),
                                                
        MaterialButton(
          shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          minWidth: 300,
          height: 50,
          child: Text('REQUEST NEW BARTER'),
          color: Colors.blueAccent,
          textColor: Colors.white,
          elevation: 15,
          onPressed: _onAddBarter,
        ),
      ],
    );
  }
                                         
  void _choose() async {
    _image =
      await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 400);
    setState(() {});
  }
                                         
  void _onAddBarter() {
    if (_image == null) {
      Toast.show(
        "Please take picture", 
        context,
        duration: Toast.LENGTH_LONG, 
        gravity: Toast.BOTTOM);
      return;
    }
    if (_bartercontroller.text.isEmpty) {
      Toast.show(
        "Please enter barter title", 
        context,
        duration: Toast.LENGTH_LONG, 
        gravity: Toast.BOTTOM
      );
      return;
    }
    if (_pricecontroller.text.isEmpty) {
      Toast.show(
        "Please enter barter price", 
        context,
        duration: Toast.LENGTH_LONG, 
        gravity: Toast.BOTTOM
      );
      return;
    }
    ProgressDialog pr = new ProgressDialog(
      context,
      type: ProgressDialogType.Normal, 
      isDismissible: false
    );
    pr.style(message: "Requesting...");
    pr.show();
    String base64Image = base64Encode(_image.readAsBytesSync());
    print(_currentPosition.latitude.toString() +
    "/" +
    _currentPosition.longitude.toString());

    http.post(urlUpload, body: {
      "encoded_string": base64Image,
      "email": widget.user.email,
      "bartertitle": _bartercontroller.text,
      "barterdesc": _desccontroller.text,
      "barterprice": _pricecontroller.text,
      "latitude": _currentPosition.latitude.toString(),
      "longitude": _currentPosition.longitude.toString(),
      "credit": widget.user.credit,
      "rating": widget.user.rating
    }).then((res) {
      print(urlUpload);
      Toast.show(
        res.body, 
        context,
        duration: Toast.LENGTH_LONG, 
        gravity: Toast.BOTTOM
      );
      if (res.body.contains("success")) {
        _image = null;
        _bartercontroller.text = "";
        _pricecontroller.text = "";
        _desccontroller.text = "";
        pr.dismiss();
        print(widget.user.email);
        _onLogin(widget.user.email, context);
      } else {
        pr.dismiss();
        Toast.show(
          res.body + ". Please reload", 
          context,
          duration: Toast.LENGTH_LONG, 
          gravity: Toast.BOTTOM
        );
      }
    }).catchError((err) {
      print(err);
      pr.dismiss();
    });
  }
                                         
  _getCurrentLocation() async {
    geolocator
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
      .then((Position position) {
        setState(() {
        _currentPosition = position;
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
      });
    } catch (e) {
      print(e);
    }
  }
                                         
  void _onLogin(String email, BuildContext ctx) {
    http.post(urlgetuser, body: {
      "email": email,
    }).then((res) {
        print(res.statusCode);
        var string = res.body;
        List dres = string.split(",");
        print(dres);
        if (dres[0] == "success") {
          User user = new User(
            name: dres[1],
            email: dres[2],
            phone: dres[3],
            radius: dres[4],
            credit: dres[5],
            rating: dres[6]);
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (context) => MainScreen(user: user))
          );
        }
    }).catchError((err) {
        print(err);
    });
  }
                                         
  void _loadmap() async {
    LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
        PlacePicker("AIzaSyAvIHhXiQ7TxWE2L7WY_qP2WpBDrR7TWHk")));
    print("MAP SHOW:");
    print(result);
  }

}