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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    List<double> marbleXPos = new List(9);
    List<double> marbleYPos = new List(9);

    for(int i = 0; i < 9; i++) {
      marbleXPos[i] = 25.0 * i + 85;
      marbleYPos[i] = 25.0 * (i % 3) + 500;
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          marblesgame(
            marblesOffset: [Offset(marbleXPos[0],marbleYPos[0]),
            Offset(marbleXPos[1],marbleYPos[1]),
            Offset(marbleXPos[2],marbleYPos[2]),
            Offset(marbleXPos[3],marbleYPos[3]),
            Offset(marbleXPos[4],marbleYPos[4]),
            Offset(marbleXPos[5],marbleYPos[5]),
            Offset(marbleXPos[6],marbleYPos[6]),
            Offset(marbleXPos[7],marbleYPos[7]),
            Offset(marbleXPos[8],marbleYPos[8])],
            //offset1: Offset(100.0,100.0),
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
  List<Offset> marblesOffset = new List(9);
  Offset offset1;

  marblesgame({Key key, this.offset1, this.marblesOffset}) : super(key: key);

  @override
  _MarblesGameState createState() => _MarblesGameState();
}

class _MarblesGameState extends State<marblesgame> with TickerProviderStateMixin {
  //add variables

  initState() {
    super.initState();
  }

  dispose() {
    super.dispose();
  }

  void _incrementCounter() {

  }

  //game variables that should not change with set State.


  @override
  Widget build(BuildContext context) {
    //force portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,

    ]);

    //get width and height of screen
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    //create marbles
    var marbleChildren = <Widget>[
    ];

    for(int i = 0; i < 9; i++) {
      var marble = new Positioned(
        top: widget.marblesOffset[i].dy,
        left: widget.marblesOffset[i].dx,
        child: Draggable(
          data: i,
          child: marbleWidget(),
          feedback: marbleWidget(),
          childWhenDragging: new Opacity(opacity: 0.0, child:marbleWidget()),
          onDraggableCanceled: (v,o) {
            setState(() { widget.marblesOffset[i] = Offset(o.dx, o.dy + widget.height - 75);});
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
          new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(image: new AssetImage("assets/marbles_game/colored_talltrees.png"),
                  fit: BoxFit.fill),
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
              onWillAccept: (data) {
                return true;
              },
              onAccept: (int data) {
                setState(() {
                  if(data <=5 ) {
                    widget.marblesOffset[data] =
                        Offset(screenWidth/4 + 25*data, screenHeight / 1.7);
                  }
                  else {
                    widget.marblesOffset[data] =
                        Offset(screenWidth/3 + 30*(data - 6), screenHeight / 1.9);
                    }
                });
              },
            ),
          ),
          new Positioned(
            child: new Stack(
              //alignment: FractionalOffset.center,
              //overflow: Overflow.visible,
              children: marbleChildren,
            ),
          ),
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
