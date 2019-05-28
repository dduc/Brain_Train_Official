import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audio_cache.dart';
import 'dart:math';
import 'dart:io';
import 'package:sensors/sensors.dart';
import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

//get relevant user info
import 'package:brain_train_official/main.dart' as login;

// BT API related Imports
import 'package:http/http.dart' as http;

//get child tracking info
import 'package:brain_train_official/profile.dart' as profile;

//class for area the animation will be played
class AnimationCanvasWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var assetsImage = new AssetImage(('assets/marbles_game/number0.png'));
    return Container (child: Image(image:assetsImage, width: screenWidth, height: screenHeight,));
  }
}

//Sound manager for sounds that require more control
class SoundManager {
  AudioPlayer audioPlayer = new AudioPlayer();

  Future playLocal(localFileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = new File("${dir.path}/$localFileName");
    if (!(await file.exists())) {
      final soundData = await rootBundle.load("assets/marbles_game/$localFileName");
      final bytes = soundData.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    }
    await audioPlayer.play(file.path, isLocal: true);
  }
  Future stop() async {
    await audioPlayer.stop();
  }
}

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
      marbleXPos[i] = screenWidth/20 * i + screenWidth/4.5;
      marbleYPos[i] = screenHeight/20 * (i % 3) + screenHeight/1.35;
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

//accelerometer events


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

//variables that should not change with game state
bool animationInit = true;
double animationOpacity = 0;

StreamSubscription soundStream;

//accelerometer
AccelerometerEvent accelerometer;
Timer accelerometerStep;
StreamSubscription<AccelerometerEvent> e;

class _MarblesGameState extends State<marblesgame> with TickerProviderStateMixin {
  //add variables
  bool isActive = false;
  int numberOfMarbles = 0;
  List<int> marbleState = new List(9);

  ////variables for animations
  AnimationController numbersAnimationController;
  Animation numbersAnimation;

  //get child ID for later insert
  String cid = profile.activeChildID;

  //var for timer
  var start;

  //game name
  String gameName = "marbles";

  //Score tracker
  int moves = 0;

  initState() {
    super.initState();

    //timer for how long child played
    start = DateTime.now();

    //initialize the state of the marbles
    for(int i = 0; i < 9; i++)
    {
      marbleState[i] = 0;
    }

    animationInit = true;
    numbersAnimationController =
    new AnimationController(vsync: this, duration: Duration(seconds: 4));
    numbersAnimationController.duration = Duration(seconds: 4);
    numbersAnimation = new CurvedAnimation(
        parent: numbersAnimationController, curve: Curves.easeIn);
    numbersAnimation.addListener(() {
      setState(() {});
    });

    //initialize listening of accelerometer events
    e = accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        accelerometer = event;
      });
    });

    //initialize timer to periodically listen for events.
    accelerometerStep = Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() {
        _shakeDetection();
      });
    });
  }

  double lastx = 0;
  double lasty = 0;
  double lastz = 0;

  //function to check if shaking phone
  void _shakeDetection() {

    double speed = ((accelerometer.x + accelerometer.y + accelerometer.z -
                      lastx - lasty - lastz)/200 * 5000).abs();

    if(speed < 20)
    {
        isActive = false;
    }

    if(speed > 400)
    {
      if(isActive == false) {
        if(numberOfMarbles > 0) {
          soundManager.playLocal("marble_shake.mp3")
              .then((onValue) {
            //do something?
          });
        }

        //increment move score, for doing hand movement for motor skills
        moves++;

        isActive = true;
      }
    }
    lastx = accelerometer.x;
    lasty = accelerometer.y;
    lastz = accelerometer.z;
  }


  //function to insert game session
  void insMotorSkillsGameInfo(String gname,int m,var s, var e,String cid) async {
    print("inserting game info...");
    String stars = "";

    //Star logic (for now)
    if (m >= 8) {
      print("3 stars");
      stars = "3";
    }

    if (m < 8 && m > 3) {
      print("2 stars");
      stars = "2";
    }

    if (m <= 3 && m >= 1) {
      print("1 star");
      stars = "1";
    }

    if (m == 0) {
      print("0 stars");
      stars = "0";
    }

    Map<String, dynamic> playmot = {
      'stars': stars,
      'game_name': gname,
      'start_time': s.toString(),
      'end_time': e.toString(),
      'Player_id': cid
    };

    String plmo = json.encode(playmot);

    final response = await http.post(
        'https://braintrainapi.com/btapi/player_motor_skillss',
        headers: {"Content-Type": "application/json"}, body: plmo);
    if (response.statusCode == 200) {
      print("Game session inserted into DB");
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
    }
    else {
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
      throw Exception('Failed to retrieve API data');
    }
  }


  //dispose accelerometer events, sounds, and animations.
  ////Dispose function is called whenever exiting the current state object
  ///(current screen), for example when pressing the back button
  ////or calling Navigator.pop(context).
  dispose() {
    numbersAnimationController.dispose();
    super.dispose();

    //Insert info to DB for game session
    var end = DateTime.now();
    insMotorSkillsGameInfo(gameName,moves,start,end,cid);

    //cancel accelerometer timer and event listener
    accelerometerStep.cancel();
    e.cancel();
    soundStream.cancel();
  }

  //functions for checking collisions
  bool _collisionFromLeft(Offset x, Offset y, int width, int height) {
    if(x.dx + width >= y.dx && x.dx < y.dx && x.dy + height > y.dy && x.dy < y.dy) {
      return true;
    }
    else
      return false;
  }
  bool _collisionFromRight(Offset x, Offset y, int width, int height) {
    if(x.dx <= y.dx + width && x.dx + width > y.dx + width && x.dy + height > y.dy && x.dy < y.dy + height) {
      return true;
    }
    else
      return false;
  }
  bool _collisionFromTop(Offset x, Offset y, int width, int height) {
    if(x.dy <= y.dy + height && x.dy + height > y.dy + height && x.dx < y.dx + width && x.dx + width > y.dx) {
      return true;
    }
    else return false;
  }
  bool _collisionFromBottom(Offset x, Offset y, int width, int height) {
    if(x.dy + height >= y.dy && x.dy < y.dy && x.dx < y.dx + width && x.dx + width > y.dx) {
      return true;
    }
    else
      return false;
  }




  //game variables that should not change with set State.
  SoundManager soundManager = new SoundManager();
  AudioPlayer audioPlayer = new AudioPlayer();

  bool onLeaveCalled = false;

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

    //set positions according to different screen sizes
    double screenOffset = -5;
    if(screenWidth > 420)
    {
        screenOffset = 10;
    }

    //function to accept and remove marbles
    void _acceptMarble(int marbleNumber) {
      if(numberOfMarbles < 9 && marbleState[marbleNumber] == 0) {
        soundStream = Future.delayed(const Duration(milliseconds: 0), () {
          soundManager.playLocal("sound$numberOfMarbles.mp3").then((onValue) {
            //do something?
          });
        }).asStream().listen((NULL) {

        });
        numberOfMarbles++;

        //give 2 points for 6 or more marbles in jar
        if(numberOfMarbles >= 6) {
          moves = moves + 2;
        }

        //give 1 points for 2-5 marbles in jar
        if(numberOfMarbles >= 2 && numberOfMarbles <= 5) {
          moves++;
        }

        marbleState[marbleNumber] = 1;
      }

      animationInit = false;
      numbersAnimationController.forward(from: 0.0);
      if(marbleNumber <=5 ) {
        widget.marblesOffset[marbleNumber] =
            Offset(screenWidth/3.7 + 25*marbleNumber + screenOffset, screenHeight / 1.7);
      }
      else {
        widget.marblesOffset[marbleNumber] =
            Offset(screenWidth/3 + 30*(marbleNumber - 6) + screenOffset, screenHeight / 1.9);
      }
    }
    void _removeMarble(int marbleNumber)
    {
      if(numberOfMarbles > 0 && marbleState[marbleNumber] == 1) {
        numberOfMarbles--;
        marbleState[marbleNumber] = 0;
        if(numberOfMarbles != 0) {
          soundStream =
              Future.delayed(const Duration(milliseconds: 0), () {
                soundManager.playLocal("sound$numberOfMarbles.mp3")
                    .then((onValue) {
                  //do something?
                });
              }).asStream().listen((NULL) {

              });
        }
      }

      numbersAnimationController.forward(from: 0.0);
    }

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
            setState(() {
              if(onLeaveCalled == false)
              {
               _removeMarble(i);
              }
              onLeaveCalled = false;

              widget.marblesOffset[i] = Offset(o.dx, o.dy + widget.height - 75);
              for(int j = 0; j < 9; j++)
              {
                if((_collisionFromLeft(widget.marblesOffset[i], widget.marblesOffset[j],
                    75, 75) ||
                _collisionFromRight(widget.marblesOffset[i], widget.marblesOffset[j],
                    75, 75) ||
                _collisionFromTop(widget.marblesOffset[i], widget.marblesOffset[j],
                    75, 75) ||
                _collisionFromBottom(widget.marblesOffset[i], widget.marblesOffset[j],
                    75, 75)) && marbleState[j] == 1)
                {
                    _acceptMarble(i);
                }
              }
            });
          },
        ),
      );
      marbleChildren.add(marble);
    }

    //Animation
    var stackChildren = <Widget>[
    ];

    animationOpacity = (1 - numbersAnimation.value);
    if(animationInit == true) {
      animationOpacity = 0;
    }

    //create animation
    //for(int i = 0;i < 20; ++i) {
      //var currentAngle = (firstAngle + ((2*pi)/5)*(i));
      var animationWidget =
      new Positioned(child: new Transform.rotate(
          angle: 0,
          child: new Opacity(opacity: animationOpacity,
              child : new Image.asset("assets/marbles_game/number$numberOfMarbles.png"))
      ),
        left: screenWidth/2.3,
        top: screenHeight/8,
      );
      stackChildren.add(animationWidget);
    //}


    return new Scaffold(
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
          new Positioned(
            child: new Stack(
              children: stackChildren,
            ),
          ),
          new Positioned(left: screenWidth/2 - (300)/2,
            top: screenHeight/2 - (300)/2,
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
                print(data);
                setState(() {
                  _acceptMarble(data);
                });
              },
              onLeave: (int data) {
                _removeMarble(data);
                onLeaveCalled = true;
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
