import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'dart:io';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/foundation.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) exit(1);
  };
  runApp(MaterialApp(
    home: MyMainPage(),
  ));
}

class MyMainPage extends StatefulWidget {
  @override
  _MyMainPageState createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLogged = false;
  FirebaseUser myUser;
  //String ;
  Future<FirebaseUser> _loginWithFacebook() async {
    var facebookLogin = new FacebookLogin();
    var result = await facebookLogin.logIn(['email']);

    debugPrint(result.status.toString());

    if (result.status == FacebookLoginStatus.loggedIn) {
      FacebookAccessToken facebookAccessToken = result.accessToken;
      AuthCredential authCredential = FacebookAuthProvider.getCredential(
          accessToken: facebookAccessToken.token);
      FirebaseUser user =
          (await _auth.signInWithCredential(authCredential)).user;

      return user;
    }
    return null;
  }

  Future<FirebaseUser> _loginWithTwitter() async {
    var twitterLogin = new TwitterLogin(
      consumerKey: '**************************',
      consumerSecret: '************************************************',
    );

    final TwitterLoginResult result = await twitterLogin.authorize();

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        var session = result.session;
        AuthCredential credential = TwitterAuthProvider.getCredential(
            authToken: session.token, authTokenSecret: session.secret);
        AuthResult authResult = await _auth.signInWithCredential(credential);
        FirebaseUser user = authResult.user;
        return user;

        break;
      case TwitterLoginStatus.cancelledByUser:
        debugPrint(result.status.toString());
        return null;

        break;
      case TwitterLoginStatus.error:
        debugPrint(result.errorMessage.toString());
        return null;
        break;
    }
    return null;
  }

  void _logOut() async {
    await _auth.signOut().then((response) {
      isLogged = false;
      setState(() {});
    });
  }

  void _logIn() {
    _loginWithFacebook().then((response) {
      if (response != null) {
        myUser = response;
        isLogged = true;
        setState(() {});
      }
    });
  }

  void _logInTwitter() {
    _loginWithTwitter().then((response) {
      if (response != null) {
        myUser = response;
        isLogged = true;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[100],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(isLogged ? "Profile Page" : "Login Here"),
        actions: <Widget>[
          isLogged
              ? IconButton(
                  icon: Icon(Icons.power_settings_new),
                  onPressed: _logOut,
                )
              : IconButton(
                  icon: Icon(Icons.remove_red_eye),
                  onPressed: () {},
                ),
        ],
      ),
      body: Center(
          child: isLogged
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(FontAwesomeIcons.affiliatetheme,
                        color: Colors.blue[100], size: 150.0),
                    Row(
                      children: <Widget>[
                        Text('                    USER',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[100])),
                        Text('DETAILS',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.cyan[100]))
                      ],
                    ),
                    Text(
                      'Name: ' + myUser.displayName,
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Email: ' + myUser.email,
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 20,
                          fontWeight: FontWeight.normal),
                    ),
                    ClipOval(
                        child: Image.network(myUser.photoUrl,
                            cacheWidth: 200,
                            cacheHeight: 200,
                            fit: BoxFit.cover)),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(FontAwesomeIcons.airFreshener,
                        color: Colors.blue[100], size: 150.0),
                    FacebookSignInButton(
                      onPressed: _logIn,
                    ),
                    SizedBox(height: 30.0),
                    TwitterSignInButton(
                      onPressed: _logInTwitter,
                    ),
                  ],
                )),
    );
  }
}
