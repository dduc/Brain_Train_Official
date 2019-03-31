import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:sensors/sensors.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

//* individual classes created for each image as a quick solution. optimization
//will be done down the line.

//create a class for the red Square
class redSquareWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var assetsImage = new AssetImage('assets/shape_matching/tilered01.png');
    var image = new Image(image: assetsImage, width: 48, height: 48);
    return Container(child:image,);
  }
}

//create a class for the blue square
class blueSquareWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var assetsImage = new AssetImage('assets/shape_matching/tileblue01.png');
    var image = new Image(image: assetsImage, width: 48, height: 48,);
    return Container(child:image);
  }
}

//create a class for the green triangle.
class greenTriangleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var assetsImage = new AssetImage('assets/shape_matching/tilegreen07.png');
    var image = new Image(image:assetsImage, width: 48, height: 48,);
    return Container(child:image,);
  }
}

//create a class for a sound manager
class SoundManager {
  AudioPlayer audioPlayer = new AudioPlayer();

  Future playLocal(localFileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = new File("${dir.path}/$localFileName");
    if (!(await file.exists())) {
      final soundData = await rootBundle.load("assets/shape_matching/$localFileName");
      final bytes = soundData.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    }
    await audioPlayer.play(file.path, isLocal: true);
  }
  Future stop() async {
    await audioPlayer.stop();
  }
}

//create a class for the area the animation is running
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

GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();

//class for the game. was named draggableImage from experimenting with
//draggable images in flutter.
class draggableImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          DraggableWidget(
              offset1: Offset(200.0,200.0),
              offset2: Offset(100.0,300.0),
              offset3: Offset(300.0,300.0),
          ),
          //DraggableWidget (
          //    offset2: Offset(100.0, 100.0),
         // )
        ],
      ),
    );
  }
}

//widget for draggable images
class DraggableWidget extends StatefulWidget {
  double width = 100, height = 100;
  Offset offset1, offset2, offset3;

  DraggableWidget({Key key, this.offset1, this.offset2, this.offset3}) : super(key: key);

  @override
  _DraggableWidgetState createState() => _DraggableWidgetState();
}

//game state
class _DraggableWidgetState extends State<DraggableWidget> with TickerProviderStateMixin{

  //initialize variables that will be used down the line
  double _sparklesAngle = 0.0;
  AnimationController sparklesAnimationController;
  Animation sparklesAnimation;

  double sparklesOpacity = 0;
  bool animationInit = true;
  
  double textOpacity = 0;

  var rng;

  //initialize state of game
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.offset1 == null) {
      widget.offset1 = Offset(0.0, 0.0);
    }
    if(widget.offset2 == null) {
      widget.offset2 = Offset(0.0, 0.0);
    }
    if(widget.offset3 == null) {
      widget.offset3 = Offset(0.0,0.0);
    }

    //create random number generator and initialize animations.
    rng = new Random();

    sparklesAnimationController =
    new AnimationController(vsync: this, duration: Duration(seconds: 2));
    sparklesAnimationController.duration = Duration(seconds: 2);
    sparklesAnimation = new CurvedAnimation(
        parent: sparklesAnimationController, curve: Curves.easeIn);
    sparklesAnimation.addListener(() {
      setState(() {});
    });

  }

  //dispose of animations when done.
  dispose() {
    super.dispose();
    sparklesAnimationController.dispose();
  }

  /////////////////////////////////////////
  //* name of game, data for dirks database.
  String gameName = "shapematching";
  /////////////////////////////////////////


  //create a red square widget with data for the square
  Widget target = redSquareWidget();
  String answerData = "red";
  var lastNum = 0;

  //used for sound to check if game has started
  bool game_initialized = false;

  //create audio player for quick sounds and sound manager for
  //sounds that require more control (things like stop().
  AudioPlayer audioPlayer = new AudioPlayer();
  SoundManager soundManager = new SoundManager();


  //things that are built in game. updated when set state {} is called.
  @override
  Widget build(BuildContext context) {
    //force portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,

    ]);

    //stop any sound from sound manager if there is something playing
    soundManager.stop();

    //create red square, blue square, and green triangle
    redSquareWidget box = redSquareWidget();
    final box2 = blueSquareWidget();
    final box3 = greenTriangleWidget();

    //create audio cache for quick sounds
    AudioCache player = new AudioCache();
    const correctAudioPath = "shape_matching/good_job_2.mp3";

    //create doubles that contain the screen width and height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    //the opacity of animation
    var scoreOpacity = 0.0;

    //change opacity of image on the screen
    if(sparklesAnimation.value < 1 && animationInit != true)
    {
       textOpacity = 1;
    }
    else
    {
       textOpacity = 0;
    }

    //create stack of widgets that will hold all the stars for the
    //animation
    var stackChildren = <Widget>[
    ];

    //variables for animation
    var firstAngle = _sparklesAngle;
    var sparkleRadius = (sparklesAnimationController.value*10) ;
    sparklesOpacity = (1 - sparklesAnimation.value);
    if(animationInit == true)
    {
        sparklesOpacity = 0;
    }
    var _neg = -1;

    //create stars used for animation and position them depending on
    //how much time has passed after animation has started.
    for(int i = 0;i < 8; ++i) {
      var currentAngle = (firstAngle + ((2*pi)/5)*(i));
      var sparklesWidget =
      new Positioned(child: new Transform.rotate(
          angle: currentAngle - pi/2,
          child: new Opacity(opacity: sparklesOpacity,
              child : new Image.asset("assets/shape_matching/starGold.png", width: 96.0, height: 96.0, ))
      ),
        left: screenWidth/2.5 + pow(sparkleRadius,1.4)*_neg*(i+1),
        top: 400 - (sparkleRadius*50) - (sparkleRadius*2)*(i+1) + pow(sparkleRadius,2.6),
      );
      stackChildren.add(sparklesWidget);
      _neg *= -1;
    }

    //add the stars to the stack
    stackChildren.add(new Opacity(opacity: scoreOpacity, child: AnimationCanvasWidget()));

    ///////////////////////

    ////////////////////////
    ////////////////////////////////////////////////////////

    //if game was first initialized play starting sound, then
    //set game as initialized
    if(game_initialized == false)
    {

      Future.delayed(const Duration(milliseconds: 500), () {
        soundManager.playLocal("red_square_1.mp3").then((onValue) {
          //do something?
        });
      });
      game_initialized = true;
    }

    //scaffold for the game itself
    return Scaffold(
      //background image, kept in a container
      body: new Container(
        child: new Stack(
          children: <Widget>[
            new Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(image: new AssetImage("assets/shape_matching/colored_talltrees.png"),
                    fit: BoxFit.cover),
              ),
            ),
            //good job text that shows up after correct answer
            new Positioned(
              left: screenWidth/2 - 264/2,
              top: screenHeight/12,
              child: Opacity(opacity: textOpacity,  child: Image(image: AssetImage("assets/shape_matching/Good_Job.png")),)
            ),
            //stars
            new Positioned(
              child: new Stack(
                children: stackChildren,
              ),
            ),
            //the target for the shapes to be dragged to
            new Positioned(left: screenWidth/2 - 100/2,
              top: 400,
              width: 100,
              height: 100,
              child: DragTarget(
                builder:(
                    context,
                    accepted,
                    rejected,
                    ) => Opacity(child: target,opacity: 0.5),
                onWillAccept: (data) {
                  return true;
                },
                //if correct answer
                onAccept: (String data) {
                  if(data == answerData) {
                    //initialize and play animation
                    animationInit = false;
                    sparklesAnimationController.forward(from: 0.0);

                    //play "good job" sound effect
                    player.play("shape_matching/correct.ogg");
                    Future.delayed(const Duration(seconds: 1), () {
                      player.play(correctAudioPath);
                    });

                    //create new random number from random number
                    //generator to randomly pick a new shape
                    var rng = new Random();
                    var num = rng.nextInt(3);

                    while (num == lastNum)
                    {
                      num = rng.nextInt(3);
                    }

                    //pick the new shape
                    if(num == 1) {
                      answerData = "green";
                      target = greenTriangleWidget();
                      Future.delayed(const Duration(milliseconds: 2500), () {
                        soundManager.playLocal("green_triangle_1.mp3").then((onValue) {
                          //do something?
                        });
                      });
                    }
                    else if(num == 2) {
                      answerData = "blue";
                      target = blueSquareWidget();
                      Future.delayed(const Duration(milliseconds: 2500), () {
                        soundManager.playLocal("blue_square_1.mp3").then((onValue) {
                          //do something?
                        });
                      });
                    }
                    else {
                      answerData = "red";
                      target = redSquareWidget();
                      Future.delayed(const Duration(milliseconds: 2500), () {
                        soundManager.playLocal("red_square_1.mp3").then((onValue) {
                          //do something?
                        });
                      });
                    }
                    lastNum = num;
                  }
                  else {
                    //if answer is incorrect, do nothing
                  }
                },
              ),),
            // positioned for red square
            new Positioned(
              left: widget.offset1.dx,
                top: widget.offset1.dy - widget.height + 20,
              child: Draggable(
                data: "red",
                  child: box, feedback: box,
              childWhenDragging: new Opacity(opacity: 0.0, child: box),
              onDraggableCanceled: (v,o) {
                  // do nothing if drag is canceled
              },
              ),
            ),
            // positioned for blue square
            new Positioned(
              left: widget.offset2.dx,
              top: widget.offset2.dy - widget.height + 20,
              child: Draggable(
                data: "blue",
                child: box2, feedback: box2,
                childWhenDragging: new Opacity(opacity: 0.0, child: box2),
                onDraggableCanceled: (v,o) {
                  //...
                },
              ),
            ),
            // positioned for green triangle
            new Positioned(
              left: widget.offset3.dx,
              top: widget.offset3.dy - widget.height + 20,
              child: Draggable(
                data: "green",
                child: box3, feedback: box3,
                childWhenDragging: new Opacity(opacity: 0.0, child: box3),
                onDraggableCanceled: (v,o) {
                  //...
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}