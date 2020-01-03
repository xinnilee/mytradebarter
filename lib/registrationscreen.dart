import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:mytradebarter/loginscreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';


String pathAsset = 'assets/images/MyTradeBarter_login.PNG'; 
String urlUpload = "http://tradebarterflutter.com/mytradebarter/php/register_user.php";
File _image;

final TextEditingController _namecontroller = TextEditingController();
final TextEditingController _emcontroller = TextEditingController();
final TextEditingController _passcontroller = TextEditingController();
final TextEditingController _phcontroller = TextEditingController();
final TextEditingController _radiuscontroller = TextEditingController();
String _name,_email,_password,_phone,_radius;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterUserState createState() => _RegisterUserState();
  const RegisterScreen({Key key, File image}) : super(key: key);
}

class _RegisterUserState extends State<RegisterScreen> {
  @override
  void initState(){
    super.initState();
  }
 
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('NEW USER REGISTRATION'),
          backgroundColor: Colors.blueGrey,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background.png"),
              fit: BoxFit.cover
            ),
          ),
          padding: EdgeInsets.fromLTRB(40,20,40,20),
          child: RegisterWidget(),
        ),
      ),
    );
  }

  Future<bool> _onBackPressAppBar() async {
    _image = null;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ));
    return Future.value(false);
  }
}

class RegisterWidget extends StatefulWidget {
  @override
  RegisterWidgetState createState() => RegisterWidgetState();
}

class RegisterWidgetState extends State<RegisterWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: _choose,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: _image == null
                  ? AssetImage(pathAsset)
                  : FileImage(_image),
                fit: BoxFit.fill,
              )
            ),
          )
        ),

        Text(
          'Click on image above to take profile picture',
          style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
        ),
        

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 20
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 3
              )
            ],
          ),
      
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _emcontroller,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  icon: Icon(Icons.email),
                ),
              ),

              TextField(
                controller: _namecontroller,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Name',
                  icon: Icon(Icons.person),
                ),
              ),

              TextField(
                controller: _passcontroller,
                decoration: InputDecoration(
                  labelText: 'Password',
                  icon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),

              TextField(
                controller: _phcontroller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone number',
                  icon: Icon(Icons.phone),
                ),
              ),

              TextField(
                controller: _radiuscontroller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Radius',
                  icon: Icon(Icons.blur_circular),
                ),
              ),

              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    color: Colors.blue[200],
                    minWidth: 100,
                    height: 50,
                    child: Text('Register',
                      style: TextStyle(fontSize: 16),
                    ),
                    textColor: Colors.black,
                    highlightColor: Colors.green[200],
                    elevation: 15,
                    onPressed: _onRegister,
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 10),

        GestureDetector(
          onTap: _onBackPress,
          child: Text('Already Register',
            style: TextStyle(
              fontSize: 16
            ),
          ),
        ),

      ],
    );
  }

  void _choose() async {
    _image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {});
  }

  void _onRegister() {
    print('onRegister Button from RegisterUser()');
    print(_image.toString());
    uploadData();
  }

  void _onBackPress() {
    _image = null;
    print("onBackPress from RegisterUser");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => LoginPage()
      )
    );
  }

  void uploadData() {
    _name = _namecontroller.text;
    _email = _emcontroller.text;
    _password = _passcontroller.text;
    _phone = _phcontroller.text;
    _radius = _radiuscontroller.text;

    if((_isEmailValid(_email)) &&
      (_password.length > 5) && 
      (_image != null) && 
      (_phone.length > 5) && 
      (int.parse(_radius) < 30)) {
        ProgressDialog pr = new ProgressDialog
        (
          context, 
          type: ProgressDialogType.Normal, isDismissible: false
        );
        pr.style(message: "Registration in progress");
        pr.show();

        String base64Image = base64Encode(_image.readAsBytesSync());
        http.post(urlUpload, body: {
          "encoded_string": base64Image,
          "name": _name,
          "email": _email,
          "password": _password,
          "phone": _phone,
          "radius": _radius,
        }).then((res) {
          print(res.statusCode);
          Toast.show
          (
            res.body, 
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM
          );
          _image = null;
          _namecontroller.text = '';
          _emcontroller.text = '';
          _passcontroller.text = '';
          _phcontroller.text = '';
          pr.dismiss();
          Navigator.pushReplacement
          (
            context, 
            MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
        }).catchError((err) {
          pr.dismiss();
          print(err);
        });
      } else {
        Toast.show
        (
          "Check your registration information", 
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM);
      }
  }

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  void savepref(String email, String pass) async {
    print('Inside savepref');
    _email = _emcontroller.text;
    _password = _passcontroller.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('pass', pass);
    print('Save pref $_email');
    print('Save pref $_password');
  }  

}
