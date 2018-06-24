import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  final loggedIn = await getLoggedIn();

//  runApp(new MyApp(true));
  runApp(new MyApp(loggedIn));
}

bool loggedIn = false;

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<bool> getLoggedIn() async {
  final SharedPreferences prefs = await _prefs;
  final bool _loggedIn = prefs.getBool('loggedIn') ?? false;
  return _loggedIn;
}

Future<bool> saveLoginState({loggedIn: bool}) async {
  final SharedPreferences prefs = await _prefs;
  return prefs.setBool("loggedIn", loggedIn);
}

class MyApp extends StatelessWidget {
  final bool loggedIn;

  MyApp(this.loggedIn);

  @override
  Widget build(BuildContext context) {
    var myHomePage = new HomePage();
    var loginPage = LoginPage();

    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      home: loggedIn ? myHomePage : loginPage,
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Enter your username'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your username';
                  }
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Enter your password'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'A password is required';
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: RaisedButton(
                  color: Theme.of(context).accentColor,
                  child: Text("Log In"),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      saveLoginState(loggedIn: true).then((bool loggedIn) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  final String title = 'Flutter Demo Home Page';

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
        actions: <Widget>[
          new PopupMenuButton<BuildContext>(
            onSelected: _logOut,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<BuildContext>(
                  child: new Text("Logout"),
                  value: context
                )
              ];
            },
          ),
        ],
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'You have pushed the button this many times:',
            ),
            new Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            FlatButton(
              child: Text("Log out"),
              onPressed: () {
                _logOut(context);
              },
            )
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _logOut(BuildContext context) {
    saveLoginState(loggedIn: false).then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }
}
