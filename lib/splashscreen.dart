import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mytradebarter/mainscreen.dart';
import 'package:mytradebarter/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

String _email, _password;
String urlLogin = "http://tradebarterflutter.com/mytradebarter/php/login_user.php";

void main() => runApp(SplashScreen());
 
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.blueGrey)
    );
    return MaterialApp(
      theme: new ThemeData(
        primaryColor: Colors.blueGrey,
        primarySwatch: Colors.blue,
        accentColor: Colors.blueAccent,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: new Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "assets/images/background.png"
              ),
              fit: BoxFit.cover
            ),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/MyTradeBarter_splashscreen.PNG',
                scale: 2,
              ),
              SizedBox(height: 20,),
              new ProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressIndicator extends StatefulWidget {
  @override
  _ProgressIndicatorState createState() => new _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator>
  with SingleTickerProviderStateMixin {
    AnimationController controller;
    Animation<double> animation;

    @override
    void initState(){
      super.initState();
      controller = AnimationController(
        duration: const Duration(milliseconds: 2000),vsync: this);
      animation = Tween(begin: 0.0, end: 1.0).animate(controller)
        ..addListener((){
          setState(() {
           if (animation.value > 0.9){
             loadpref(this.context);
           } 
          });
        });
      
      controller.repeat();
    }

    @override
    void dispose(){
      controller.stop();
      super.dispose();
    }

    @override
    Widget build(BuildContext content){
      return new Center(
        child: new Container(
          width: 200,
          color: Colors.redAccent,
          child: LinearProgressIndicator(
            value: animation.value,
            backgroundColor: Colors.black,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
            ),
        ));
    }

    void loadpref(BuildContext ctx) async {
      print('Inside loadpref()');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _email = (prefs.getString('email')??'');
      _password = (prefs.getString('pass')??'');
      print("Splash:Preference");
      print(_email);
      print(_password);

      if(_isEmailValid(_email??"no email")) {
        _onLogin(_email, _password, ctx);
      } else {
        User user = new User(
          name: "not register",
          email: "user@noregister",
          phone: "not register",
          radius: "30",
          credit: "0",
          rating: "0"
        );

        Navigator.push(ctx, MaterialPageRoute(builder: (context) => MainScreen(user: user)));
      }
    }
    
    bool _isEmailValid(String email){
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    }

    void _onLogin(String email, String pass, BuildContext ctx) {
      http.post(urlLogin, body: {
        "email": _email,
        "password": _password,
      }).then((res) {
        print(res.statusCode);
        var string = res.body;
        List dres = string.split(",");
        print("SPLASH:loading");
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

        } else {
          User user = new User(
            name: "not register",
            email: "user@noregister",
            phone: "not register",
            radius: "15",
            credit: "0",
            rating: "0"
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

