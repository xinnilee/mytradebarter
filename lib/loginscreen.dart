import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mytradebarter/registrationscreen.dart';
import 'package:mytradebarter/forgotscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart'as http;
import 'package:progress_dialog/progress_dialog.dart';

String urlLogin = "http://tradebarterflutter.com/mytradebarter/php/login_user.php";

void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget{
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  final TextEditingController _emcontroller = TextEditingController();
  String _email = "";
  final TextEditingController _passcontroller = TextEditingController();
  String _password = "";
  bool _isChecked = false;

  @override
  void initState(){
    loadpref();
    print('Init: $_email');
    super.initState();
  }
  
  @override
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: new Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background.png"),
              fit: BoxFit.cover
            ),
          ),

          padding: EdgeInsets.all(30.0),
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
                    TextField(
                      controller: _emcontroller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        icon: Icon(Icons.email),
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    TextField(
                      controller: _passcontroller,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        icon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    Row(
                      children: <Widget>[
                        Checkbox(
                          value:  _isChecked,
                          onChanged: (bool value){
                            _onChange(value);
                          },
                        ),
                        Text('Remember Me',
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)
                          ),
                          color: Colors.blue[200],
                          minWidth: 150,
                          height: 50,
                          child: Text('Login',
                            style: TextStyle(fontSize: 16),
                          ),
                          textColor: Colors.black,
                          highlightColor: Colors.green[200],
                          elevation: 15,
                          onPressed: _onLogin,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 20,
              ),

              GestureDetector(
                onTap:  _onRegister,
                child: Text('Register New Account',
                      style: TextStyle(fontSize: 16)
                )
              ),

              SizedBox(
                height: 20,
              ),

              GestureDetector(
                onTap: _onForgot,
                child: Text('Forgot Password',
                    style: TextStyle(fontSize: 16)
                )
              ),

            ],
          ),
        ),
      )
    );
  }

  void _onLogin(){
    _email = _emcontroller.text;
    _password = _passcontroller.text;
    if(_isEmailValid(_email)&&(_password.length>4)){
      ProgressDialog pr = new ProgressDialog(
        context, 
        type: ProgressDialogType.Normal, isDismissible: false
      );
      pr.style(message: "Login in");
      pr.show();

      http.post(urlLogin,
        body:{
          "email": _email,
          "password": _password,
        }
      ).then((res){
        print(res.statusCode);
        Toast.show(
          res.body, 
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM
        );
        if(res.body == "success"){
          pr.dismiss();
        }
        else{
          pr.dismiss();
        }
      }).catchError((err){
        pr.dismiss();
        print(err);
      });
      
    }
  }

  void _onRegister(){
    print('on Register');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen()
      ));
  }

  void _onForgot() {
    print('on Forgot');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForgotScreen()
      ));
  }

  void _onChange(bool value){
    setState((){
      _isChecked = value;
      savepref(value);
    });
  }

  void loadpref() async{
    print('Inside loadpref()');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _email = (prefs.getString('email'));
    _password = (prefs.getString('pass'));
    print(_email);
    print(_password);

    
  }

  void savepref(bool value) async{
    print('Inside savepref');
    _email = _emcontroller.text;
    _password = _passcontroller.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(value){
      if(_isEmailValid(_email)&&(_password.length > 5)){
        await prefs.setString('email', _email);
        await prefs.setString('pass', _password);
        print('Save pref $_email');
        print('Save pref $_password');
        Toast.show(
          "Preferences have been saved", 
          context,
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.BOTTOM
        );
      }
      else{
        await prefs.setString('email', '');
        await prefs.setString('pass', '');
        setState(() {
         _emcontroller.text = '';
         _passcontroller.text = '';
         _isChecked = false; 
        });
        print('Remove pref');
        Toast.show(
          "Preferences have been removed", 
          context,
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.BOTTOM
        );
      }
    }
  }


  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    print('Backpress');
    return Future.value(false);
  }

  bool _isEmailValid(String email){
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

}
