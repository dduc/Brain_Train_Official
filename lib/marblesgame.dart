import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audio_cache.dart';
import 'dart:math';
import 'package:sensors/sensors.dart';

class marbleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var assetsImage = new AssetImage('assets/marbles_game/marble.png');
    var image = new Image(image: assetsImage, width: 75, height: 75);
    return Container(child:image,);
  }
}

class marbles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          marblesgame(
            offset1: Offset(200.0,200.0),
          ),
          //DraggableWidget (
          //    offset2: Offset(100.0, 100.0),
          // )
        ],
      ),
    );
  }
}

class marblesgame extends StatefulWidget {
  //marblesngame({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  //final String title;
  double width = 75, height = 75;
  Offset offset1;

  marblesgame({Key key, this.offset1}) : super(key: key);

  @override
  _MarblesGameState createState() => _MarblesGameState();
}

class _MarblesGameState extends State<marblesgame> with TickerProviderStateMixin {
  //add variables


  initState() {
    super.initState();
    if(widget.offset1 == null) {
      widget.offset1 = Offset(0.0, 0.0);
    }
  }

  dispose() {
    super.dispose();
  }

  void _incrementCounter() {

  }

  //game variables that should not change with set State.


  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    var marbleChildren = <Widget>[
    ];

    for(int i = 0; i < 9; i++) {
      var marble = new Positioned(
        top: widget.offset1.dy,
        left: widget.offset1.dx,
        child: Draggable(
          data: "red",
          child: marbleWidget(),
          feedback: marbleWidget(),
          childWhenDragging: new Opacity(opacity: 0.0, child:marbleWidget()),
          onDraggableCanceled: (v,o) {
            setState(() { widget.offset1 = Offset(o.dx, o.dy + widget.height - 20);});
          },
        ),
      );
      marbleChildren.add(marble);
    }

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
          new Positioned(
              child: new Stack(
                //alignment: FractionalOffset.center,
                //overflow: Overflow.visible,
                children: marbleChildren,
              ),
          ),
          new Positioned(left: screenWidth/2 - 300/2,
            top: screenHeight/2 - 300/2,
            width:  300,
            height: 300,
            child: DragTarget(
              builder:(
                  context,
                  accepted,
                  rejected,
                  ) => Opacity(child:  Image.asset("assets/marbles_game/jar.png"),opacity: 1),
              //Container(
              //width: 100,
              //height: 100,
              //color: Colors.amberAccent,
              //child: Center(child: Text(acceptedData.toString())),
              //),
              onWillAccept: (data) {
                return true;
              },
              onAccept: (String data) {
              },
            ),),
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
      */ // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
