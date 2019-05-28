import 'package:flutter/material.dart';
import 'package:brain_train_official/profile.dart';
import 'package:brain_train_official/widgets.dart';
import 'dart:math';
import 'package:audioplayers/audio_cache.dart';
import 'package:brain_train_official/memorygame.dart';
import 'package:brain_train_official/balloongame.dart';
import 'package:brain_train_official/thisOrThat.dart';
import 'package:brain_train_official/marblesgame.dart';

//get login info
import 'package:brain_train_official/main.dart' as login;

//get child tracking info
import 'package:brain_train_official/profile.dart' as profile;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AudioCache player = new AudioCache();
    const correctAudioPath = "correct.ogg";

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: new Scaffold(body: MyHomePage(title: 'Shape matching game')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  var rng;

  final duration = new Duration(milliseconds: 400);

  initState() {
    super.initState();

    rng = new Random();
  }

  dispose() {
    super.dispose();

    //this is logging out essentially,backing out of title page to login page
    //here, delete all cached information
    login.MyApp.cuname = [];
    login.MyApp.cage = [];
    login.MyApp.cid = [];
    profile.activeChild = '';
    profile.color = [];
    profile.toggle = [];
    profile.activeChildID = '';
    profile.someData = false;
    login.MyApp.tcuname = [];
    login.MyApp.tcage = [];
    login.MyApp.tcid = [];
    login.MyApp.tagegroup = '';
    login.MyApp.temail = '';
    login.MyApp.pemail = '';
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
    String acceptedData = "drag here";

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    var stackChildren = <Widget>[];

    var widget2 = new Positioned(
      child: new Stack(
        children: stackChildren,
      ),
    );
    return Scaffold(
      body: Stack(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage("assets/colored_castle.png"),
                  fit: BoxFit.cover),
            ),
          ),
          new Positioned(
            top: screenHeight / 10,
            left: screenWidth / 3.5,
            child: Image.asset("assets/Brain_train_title.png"),
          ),

          //36 x 36 profile icon to nav to profile page
          new Positioned(
              top: screenHeight / 20,
              left: screenWidth / 1.23,
              child: FlatButton(
                child: Image.asset('assets/profile_icon.png'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => userProfile()),
                  );
                },
              )),
          new Positioned(
            top: screenHeight / 2.5 - 150 / 2,
            left: screenWidth / 12,
            child: FlatButton(
              child: Image.asset("assets/memory_game_icon.png",
                  width: 125, height: 125),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MemoryGame()),
                );
              },
            ),
          ),
          new Positioned(
            top: screenHeight / 2.5 - 150 / 2,
            left: screenWidth / 1.9,
            child: FlatButton(
              child: Image.asset("assets/shape_game_icon.png",
                  width: 125, height: 125),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => draggableImage()),
                );
              },
            ),
          ),
          new Positioned(
            top: screenHeight / 1.6 - 150 / 2,
            left: screenWidth / 1.9,
            child: FlatButton(
              child: Image.asset("assets/balloon_game_icon.png",
                  width: 125, height: 125),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => balloongame()),
                );
              },
            ),
          ),
          new Positioned(
            top: screenHeight / 1.18 - 150 / 2,
            left: screenWidth / 3.3,
            child: FlatButton(
              child: Image.asset("assets/jar_game_icon.png",
                  width: 125, height: 125),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => marbles()),
                );
              },
            ),
          ),
          new Positioned(
            top: screenHeight / 1.6 - 150 / 2,
            left: screenWidth / 12,
            child: FlatButton(
              child: Image.asset("assets/this_or_that2.jpg",
                  width: 125, height: 125),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThisOrThat()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
