import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:mytradebarter/loginscreen.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
 
String pathAsset = 'assets/images/MyTradeBarter_login.PNG'; 
String urlReset = "http://tradebarterflutter.com/mytradebarter/php/forgot_password.php";

final TextEditingController _emcontroller = TextEditingController();
String _email;

class ForgotScreen extends StatefulWidget {
  @override
  _ResetPageState createState() => _ResetPageState();
  const ForgotScreen({Key key}) : super(key: key);
}

class _ResetPageState extends State<ForgotScreen>{
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
          title: Text('RECOVER PASSWORD'),
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
          child: ResetWidget(),
        ),
      ),
    );
  }

Future<bool> _onBackPressAppBar() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ));
    return Future.value(false);
  }
}

class ResetWidget extends StatefulWidget {
  @override
  ResetWidgetState createState() => ResetWidgetState();
}

class ResetWidgetState extends State<ResetWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(  
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 20,
          ),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/MyTradeBarter_login.PNG',
                scale: 1.5,
              ),

              SizedBox(
                height: 40,
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
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
                    Text(
                      'Please enter your email address to reset password',
                      style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                    ),

                    TextField(
                      controller: _emcontroller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        icon: Icon(Icons.email),
                        
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
                          child: Text('Send',
                            style: TextStyle(fontSize: 16),
                          ),
                          textColor: Colors.black,
                          highlightColor: Colors.green[200],
                          elevation: 15,
                          onPressed: _onSend,
                        ),
                      ],
                    ),

                  ],
                ),
              ),

              SizedBox(height: 10),

              GestureDetector(
                onTap: _onBackPress,
                child: Text('Back to login page',
                  style: TextStyle(
                    fontSize: 16
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onSend() {
    print('onSend Button from ForgotPassword()');
    onReset();
  }

    void _onBackPress() {
    print("onBackPress from ForgotPassword()");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => LoginPage()
      )
    );
  }

  void onReset() {
    _email = _emcontroller.text;

    if(_isEmailValid(_email)) {
        ProgressDialog pr = new ProgressDialog
        (
          context, 
          type: ProgressDialogType.Normal, isDismissible: false
        );
        pr.style(message: "Reset password in progress");
        pr.show();

        http.post(urlReset, body: {
          "email": _email,
        }).then((res) {
          print(res.statusCode);
          Toast.show
          (
            res.body, 
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM
          );
          _emcontroller.text = '';
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
          "Check your email", 
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM);
      }
  }

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

}