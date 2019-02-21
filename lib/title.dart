import 'package:flutter/material.dart';
import 'package:brain_train_official/widgets.dart';
import 'package:flutter/animation.dart';
import 'dart:math';
import 'package:audioplayers/audio_cache.dart';
import 'package:brain_train_official/memorygame.dart';
import 'package:brain_train_official/balloongame.dart';

//void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AudioCache player = new AudioCache();
    const correctAudioPath = "correct.ogg";

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: new Scaffold(body: MyHomePage(title: 'Shape matching game')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  int _counter = 0;

  var rng;

  final duration = new Duration(milliseconds: 400);
  //final duration = new Duration(seconds: 2);
  //final oneSecond = new Duration(seconds: 1);

  initState() {
    super.initState();

    rng = new Random();
  }

    dispose() {
      super.dispose();
    }

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
    GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
    String acceptedData = "drag here";

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    var stackChildren = <Widget>[
    ];

    var widget2 =  new Positioned(
        child: new Stack(
          //alignment: FractionalOffset.center,
          //overflow: Overflow.visible,
          children: stackChildren,
        )
        ,
        //left: screenWidth/2,
        //top: screenHeight/2,
        //bottom: 50
    );
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      //appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
      //  title: Text(widget.title),
      //),
      body: Stack(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
      //child: new redSquareWidget()
      children: <Widget>[
        //new Center(
          //child: new Text("Hello background"),
       //   child: draggableImage(),
       // )
        //widget2,
        //draggableImage(),
        new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(image: new AssetImage("assets/colored_castle.png"),fit: BoxFit.cover),
          ),
        ),
        new Positioned(
          top: screenHeight/14,
          left: screenWidth/3.5,
          child: Image.asset("assets/Brain_train_title.png"),
        ),
        new Positioned(
          top: screenHeight/2.5 - 150/2,
          left: screenWidth/12,
          child: FlatButton(
              child: Image.asset("assets/memory_game_icon.png"),
              onPressed: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => MemoryGame()),);
              },),
        ),
        new Positioned(
          top: screenHeight/2.5 - 150/2,
          left: screenWidth/1.9,
          child: FlatButton(
            child: Image.asset("assets/shape_game_icon.png"),
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => draggableImage()),);
            },),
        ),
        new Positioned(
          top: screenHeight/1.5 - 150/2,
          left: screenWidth/1.9,
          child: FlatButton(
            child: Image.asset("assets/balloon_game_icon.png"),
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => balloongame()),);
            },),
        ),
        /*
        new Positioned(
          left: 140,
          top: 40,
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('find the red square:  ',),
          smallredSquareWidget(),
        ],
      ),
        ),
        */
      ],
      ),
      /*  child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      */
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
