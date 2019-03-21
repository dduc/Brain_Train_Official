import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audio_cache.dart';
import 'dart:math';
import 'package:sensors/sensors.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

//The class for the balloon game
class balloongame extends StatefulWidget {
  //balloongame({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  //final String title;

  @override
  _BalloonGameState createState() => _BalloonGameState();
}

//Sound manager for sounds that require more control
class SoundManager {
  AudioPlayer audioPlayer = new AudioPlayer();

  Future playLocal(localFileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = new File("${dir.path}/$localFileName");
    if (!(await file.exists())) {
      final soundData = await rootBundle.load("assets/balloon_game/$localFileName");
      final bytes = soundData.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    }
    await audioPlayer.play(file.path, isLocal: true);
  }
  Future stop() async {
    await audioPlayer.stop();
  }
}

//class for area the animation will be played
class AnimationCanvasWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var assetsImage = new AssetImage(('assets/shape_matching/tilered01.png'));
    return Container (child: Image(image:assetsImage, width: screenWidth, height: screenHeight,));
  }
}


//game state
class _BalloonGameState extends State<balloongame> with TickerProviderStateMixin {
  //add variables
  AnimationController sparklesAnimationController;
  Animation sparklesAnimation;

  double sparklesOpacity = 0;
  double textOpacity = 0;
  bool animationInit = true;

  //initialize game state
  initState() {
    super.initState();

    sparklesAnimationController =
    new AnimationController(vsync: this, duration: Duration(seconds: 4));
    sparklesAnimationController.duration = Duration(seconds: 4);
    sparklesAnimation = new CurvedAnimation(
        parent: sparklesAnimationController, curve: Curves.easeIn);
    sparklesAnimation.addListener(() {
      setState(() {});
    });
  }

  //dispose of animation when done
  dispose() {
    super.dispose();
    sparklesAnimationController.dispose();
  }

  //game variables that should not change with set State.
  var lastnum = 0;

  //random number generator
  var rng = new Random();
  var num = 1;
  var correctcount = 2;

  var rng2 = new Random();
  var num2 = 2;

  var incorrectnum1 = 3;
  var incorrectnum2 = 4;

  //sound manager
  SoundManager soundManager = new SoundManager();
  bool soundInterupted = false;

  //create audio cache for quick sounds
  AudioCache player = new AudioCache();

  //flag to check if game was first initialized
  bool game_initialized = false;

  //build for game. updated when "set state {}" is called.
  @override
  Widget build(BuildContext context) {

    //variables for screen width and height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    //check if game is initialized, if it is first started play sound then
    //set game as initialized
    if(game_initialized == false)
    {

      Future.delayed(const Duration(milliseconds: 500), () {
        soundManager.playLocal("balloons_1.mp3").then((onValue) {
          //do something?
        });
      });
      game_initialized = true;
    }

    //stack variable to keep balloon images
    var balloonChildren = <Widget>[
    ];

    //balues that move the balloons to the correct positions
    double topvalue, leftvalue;
    double offsetvalue = 1;
    double offsetvalue2 = 1;
    if(num == 1)
    {
        offsetvalue = 1.5;
    }
    if(num == 3)
    {
        offsetvalue2 = .75;
    }

    //set the positions of the balloons depending on how many baloons
    //are on the screen
    for(int i = 0; i < num + 1; ++i)
    {
      //set positions of balloons
      if(i == 0)
        {
          topvalue = screenHeight/2 - 125/2;
          leftvalue = screenWidth/2*offsetvalue - 59/2;
        }
      if(i == 1)
        {
          topvalue = screenHeight/2 - 125/2;
          leftvalue = screenWidth/6*offsetvalue - 59/2;
        }
      if(i == 2)
        {
          topvalue = screenHeight/2 - 125/2;
          leftvalue = screenWidth/1.2 - 59/2;
        }
      if(i == 3)
        {
          topvalue = screenHeight/4 - 125/2;
          leftvalue = screenWidth/1.5*offsetvalue2 - 59/2;
        }
      if(i == 4)
        {
          topvalue = screenHeight/4 - 125/2;
          leftvalue = screenWidth/3 - 59/2;
        }

      //create balloons
      var balloon = new Positioned(
          top: topvalue,
          left: leftvalue,
          child: Image.asset("assets/balloon_game/red_balloon.png"),
        );
      balloonChildren.add(balloon);
    }

    //strings for the numbers at the bottom of the screen
    var string1 = "assets/balloon_game/number1.png";
    var string2 = "assets/balloon_game/number2.png";
    var string3 = "assets/balloon_game/number3.png";


    //set the numbers at the bottom of the screen.
    if(num2 == 0)
    {
      string1 = "assets/balloon_game/number$correctcount.png";
      string2 = "assets/balloon_game/number$incorrectnum1.png";
      string3 = "assets/balloon_game/number$incorrectnum2.png";
    }
    else if(num2 == 1)
    {
      string2 = "assets/balloon_game/number$correctcount.png";
      string1 = "assets/balloon_game/number$incorrectnum1.png";
      string3 = "assets/balloon_game/number$incorrectnum2.png";
    }
    else if (num2 == 2)
    {
      string3 = "assets/balloon_game/number$correctcount.png";
      string2 = "assets/balloon_game/number$incorrectnum1.png";
      string1 = "assets/balloon_game/number$incorrectnum2.png";
    }

    //Animation
    var stackChildren = <Widget>[
    ];

      //variables for animation
    double _sparklesAngle = 0.0;
    var confettinum = 1;
    var _neg = -1;

    var firstAngle = _sparklesAngle;
    sparklesOpacity = (1 - sparklesAnimation.value);
    if(animationInit == true)
    {
      sparklesOpacity = 0;
    }

    if(sparklesAnimation.value < 1 && animationInit != true)
    {
      textOpacity = 1;
    }
    else
    {
      textOpacity = 0;
      soundInterupted = false;
    }

    //create confetti
    for(int i = 0;i < 20; ++i) {
      var currentAngle = (firstAngle + ((2*pi)/5)*(i));
      var sparklesWidget =
      new Positioned(child: new Transform.rotate(
          angle: currentAngle - pi/2,
          child: new Opacity(opacity: sparklesOpacity,
              child : new Image.asset("assets/balloon_game/confetti$confettinum.png", width: 96.0, height: 96.0, ))
      ),
        left: screenWidth - (i+1)*(screenWidth/20) - 30,
        top: screenHeight - screenHeight*sparklesOpacity + 25*(i%8)*_neg,
      );
      confettinum++;
      _neg *= -1;
      if(confettinum >= 5) {
        confettinum = 1;
      }
      stackChildren.add(sparklesWidget);
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
        children: <Widget>[
          //background
          new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(image: new AssetImage("assets/balloon_game/clouds.png"),fit: BoxFit.cover),
            ),
          ),
          //good job text
          new Positioned(
              left: screenWidth/2 - 264/2,
              top: screenHeight/12,
              child: Opacity(opacity: textOpacity,  child: Image(image: AssetImage("assets/shape_matching/Good_Job.png")),)
          ),
          //balloons
          new Positioned(
            child: new Stack(
              children: balloonChildren,
            ),
          ),
          //confetti animation
          new Positioned(
            child: new Stack(
              children: stackChildren,
            ),
          ),

          //next 3 positioned are the numbers, each one will have the same
          //variables and logic, but I will only include comments for one.
          new Positioned(
            //position of number
            top: screenHeight/1.1 - 76/2,
            left: screenWidth/10 - 37/2,
            child: FlatButton(
              child: Image.asset(string1),
              //if pressed
              onPressed: () {
                if(sparklesAnimation.value < 1 && animationInit != true)
                {
                  soundInterupted = true;
                }
                //if this is the correct number
                if(num2 == 0)
                {
                  //play "good job" sound effect
                  soundManager.playLocal("good_job_2.mp3").then((onValue) {
                    //do something?
                  });
                  Future.delayed(const Duration(milliseconds: 4500), () {
                    if(soundInterupted == false) {
                      soundManager.playLocal("balloons_1.mp3").then((onValue) {
                        //do something?
                      });
                    }
                  });

                  //initialize and start animation
                  animationInit = false;
                  sparklesAnimationController.forward(from: 0.0);

                  //create new random number for this number
                  var rng = new Random();
                  num = rng.nextInt(5);

                    //make sure it is not the same as last time
                  while (num == lastnum)
                  {
                    num = rng.nextInt(5);
                  }
                  lastnum = num;
                  correctcount = num+1;

                  //create random number for the other two numbers that are
                  //going to be the wrong answers
                  rng2 = new Random();
                  num2 = rng2.nextInt(3);

                  incorrectnum1 = rng2.nextInt(5) + 1;
                  while(incorrectnum1 == correctcount)
                  {
                    incorrectnum1 = rng2.nextInt(5) + 1;
                  }
                  incorrectnum2 = rng2.nextInt(5) + 1;
                  while(incorrectnum2 == correctcount || incorrectnum2 == incorrectnum1)
                  {
                    incorrectnum2 = rng2.nextInt(5) + 1;
                  }

                  setState(() {
                  });
                }
              },),
          ),
          new Positioned(
            top: screenHeight/1.1 - 76/2,
            left: screenWidth/2.25 - 37/2,
            child: FlatButton(
              child: Image.asset(string2),
              onPressed: () {
                if(sparklesAnimation.value < 1 && animationInit != true)
                {
                  soundInterupted = true;
                }
                if(num2 == 1)
                {
                  //play "good job" sound effect
                  soundManager.playLocal("good_job_2.mp3").then((onValue) {
                    //do something?
                  });
                  Future.delayed(const Duration(milliseconds: 4500), () {
                    if(soundInterupted == false) {
                      soundManager.playLocal("balloons_1.mp3").then((onValue) {
                        //do something?
                      });
                    }
                  });

                  //initialize animation and play
                  animationInit = false;
                  sparklesAnimationController.forward(from: 0.0);

                  //create new random number
                  var rng = new Random();
                  num = rng.nextInt(5);

                  //make sure it is not the same as last time
                  while (num == lastnum)
                  {
                    num = rng.nextInt(5);
                  }
                  lastnum = num;
                  correctcount = num+1;

                  //create random numbers for the next two incorrect
                  //numbers
                  rng2 = new Random();
                  num2 = rng2.nextInt(3);

                  incorrectnum1 = rng2.nextInt(5) + 1;
                  while(incorrectnum1 == correctcount)
                  {
                    incorrectnum1 = rng2.nextInt(5) + 1;
                  }
                  incorrectnum2 = rng2.nextInt(5) + 1;
                  while(incorrectnum2 == correctcount || incorrectnum2 == incorrectnum1)
                  {
                    incorrectnum2 = rng2.nextInt(5) + 1;
                  }

                  setState(() {
                  });
                }
              },),
          ),
          new Positioned(
            top: screenHeight/1.1 - 76/2,
            left: screenWidth/1.3 - 37/2,
            child: FlatButton(
              child: Image.asset(string3),
              onPressed: () {
                if(sparklesAnimation.value < 1 && animationInit != true)
                {
                  soundInterupted = true;
                }
                if(num2 == 2) {
                  //play "good job" sound effect
                  soundManager.playLocal("good_job_2.mp3").then((onValue) {
                    //do something?
                  });
                  Future.delayed(const Duration(milliseconds: 4500), () {
                    if(soundInterupted == false) {
                      soundManager.playLocal("balloons_1.mp3").then((onValue) {
                        //do something?
                      });
                    }
                  });

                  //initialize and play animation
                  animationInit = false;
                  sparklesAnimationController.forward(from: 0.0);

                  //create new random number
                  var rng = new Random();
                  num = rng.nextInt(5);

                  //make sure it is not the same as last time
                  while (num == lastnum)
                  {
                    num = rng.nextInt(5);
                  }
                  lastnum = num;
                  correctcount = num+1;

                  //create random numbers for the other two incorrect
                  //numbers
                  rng2 = new Random();
                  num2 = rng2.nextInt(3);

                  incorrectnum1 = rng2.nextInt(5) + 1;
                  while(incorrectnum1 == correctcount)
                  {
                    incorrectnum1 = rng2.nextInt(5) + 1;
                  }
                  incorrectnum2 = rng2.nextInt(5) + 1;
                  while(incorrectnum2 == correctcount || incorrectnum2 == incorrectnum1)
                  {
                    incorrectnum2 = rng2.nextInt(5) + 1;
                  }

                  setState(() {

                  });
                }
              },),
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
