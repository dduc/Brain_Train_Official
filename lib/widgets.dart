import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audio_cache.dart';
import 'dart:math';
import 'package:sensors/sensors.dart';

class redSquareWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var assetsImage = new AssetImage('assets/shape_matching/tilered01.png');
    var image = new Image(image: assetsImage, width: 48, height: 48);
    return Container(child:image,);
  }
}
class smallredSquareWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var assetsImage = new AssetImage('assets/shape_matching/tilered01.png');
    var image = new Image(image: assetsImage, width: 24, height: 24,color: Color.fromRGBO(255,0,0,0.5));
    return Container(child:image, );
  }
}
class blueSquareWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var assetsImage = new AssetImage('assets/shape_matching/tileblue01.png');
    var image = new Image(image: assetsImage, width: 48, height: 48,);
    return Container(child:image);
  }
}

class greenTriangleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var assetsImage = new AssetImage('assets/shape_matching/tilegreen07.png');
    var image = new Image(image:assetsImage, width: 48, height: 48,);
    return Container(child:image,);
  }
}

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



class DraggableWidget extends StatefulWidget {
  double width = 100, height = 100;
  Offset offset1, offset2, offset3;

  DraggableWidget({Key key, this.offset1, this.offset2, this.offset3}) : super(key: key);

  @override
  _DraggableWidgetState createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget> with TickerProviderStateMixin{
  double _sparklesAngle = 0.0;
  AnimationController sparklesAnimationController;
  Animation sparklesAnimation;

  var rng;
  double sparklesOpacity = 0;
  bool animationInit = true;
  
  double textOpacity = 0;

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

    //@override
    //Widget build(BuildContext context) {

    //}
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

  dispose() {
    super.dispose();
    //scoreInAnimationController.dispose();
    //scoreOutAnimationController.dispose();
    sparklesAnimationController.dispose();
  }
/*
  @override
  Widget build(BuildContext context) {
    final box = redSquareWidget();
    final box2 = blueSquareWidget();
    //final box = Container(
      //width: 100.0,
     // height: 100.0,
    //  color: Colors.blue,
    //);
    return Positioned(
      left: widget.offset.dx,
      top: widget.offset.dy - widget.height + 20,
      child: Draggable(
        child:box, feedback: box,
          //child: box, feedback: Container(
            //width: 100.0,
            //height: 100.0,
            //color:Colors.blue.withOpacity(0.3),
      //),
        childWhenDragging: new Opacity(opacity: 0.0, child: box),
        onDraggableCanceled: (v,o) {
            setState(() => widget.offset = o);
        },
      ),
     );
  }
*/

void _showDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text("Alert Dialog title example"),
        content: new Text("Alert Dialog body"),
        actions: <Widget>[
          new FlatButton(
              child: new Text("close"),
              onPressed: ()
              {
                Navigator.of(context).pop();
              },
          ),
        ],
      );
    }
  );
}

  String gameName = "shapematching";

  Widget target = redSquareWidget();
  String answerData = "red";
  var lastNum = 0;

  var lastUpdate = 0;
  double lastx,lasty,lastz;

  @override
  Widget build(BuildContext context) {

    redSquareWidget box = redSquareWidget();
    final box2 = blueSquareWidget();
    final box3 = greenTriangleWidget();

    AudioCache player = new AudioCache();
    const correctAudioPath = "correct.ogg";

    String acceptedData = "drag here";

    Positioned test, test2;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    var extraSize = 0.0;
    var scoreOpacity = 0.0;
    var scorePosition = 0.0;

    var shakeThreshold = 600;

    if(sparklesAnimation.value < 1 && animationInit != true)
    {
       textOpacity = 1;
    }
    else
      {
          textOpacity = 0;
      }

    var stackChildren = <Widget>[
    ];

    var firstAngle = _sparklesAngle;
    var sparkleRadius = (sparklesAnimationController.value*10) ;
    sparklesOpacity = (1 - sparklesAnimation.value);
    if(animationInit == true)
    {
        sparklesOpacity = 0;
    }
    var _neg = -1;
    double gravity = 1;

    for(int i = 0;i < 8; ++i) {
      var currentAngle = (firstAngle + ((2*pi)/5)*(i));
      var sparklesWidget =
      new Positioned(child: new Transform.rotate(
          angle: currentAngle - pi/2,
          child: new Opacity(opacity: sparklesOpacity,
              child : new Image.asset("assets/shape_matching/starGold.png", width: 96.0, height: 96.0, ))
      ),
        //left: pow(sparkleRadius,1.2)*cos(currentAngle) + screenWidth/2,
        //top: (sparkleRadius*sin(currentAngle)) + screenHeight/2,
        left: screenWidth/2.5 + pow(sparkleRadius,1.4)*_neg*(i+1),
        top: 400 - (sparkleRadius*50) - (sparkleRadius*2)*(i+1) + pow(sparkleRadius,2.6),
      );
      stackChildren.add(sparklesWidget);
      gravity *= 3;
      _neg *= -1;
    }

    stackChildren.add(new Opacity(opacity: scoreOpacity, child: AnimationCanvasWidget()));

    ///////////////////////
    test = new Positioned(left: 150,
      top: 400,
      width: 100,
      height: 100,
      child: DragTarget(
        builder:(
            context,
            accepted,
            rejected,
            ) => Opacity(child: box,opacity: 0.5),
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
          acceptedData = data;
          if(data == answerData) {
            Scaffold.of(context).showSnackBar(SnackBar(content: Text("good job!!")));
              answerData = "green";
              //target = test2;
          }
          else {
            Scaffold.of(context).showSnackBar(SnackBar(content: Text("try again.")));
          }
        },
      ),);

    /////////

    test2 = new Positioned(left: 150,
      top: 400,
      width: 100,
      height: 100,
      child: DragTarget(
        builder:(
            context,
            accepted,
            rejected,
            ) => Opacity(child: box3,opacity: 0.5),
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
          acceptedData = data;
          if(data == answerData) {
            Scaffold.of(context).showSnackBar(SnackBar(content: Text("good job!!")));
            answerData = "green";
          }
          else {
            Scaffold.of(context).showSnackBar(SnackBar(content: Text("try again.")));
          }
        },
      ),);
    ////////////////////////

    //target = redSquareWidget();

    ////////////ACCELEROMETER EVENTS////////////////
    //
    /*
    accelerometerEvents.listen((AccelerometerEvent event) {
          //code
      double x = event.x;
      double y = event.y;
      double z = event.z;

      var time = new DateTime.now().millisecondsSinceEpoch;
      //Scaffold.of(context).showSnackBar(SnackBar(content: Text(time.toString())));

      if(time - lastUpdate > 10) {
        var diff = time - lastUpdate;
        lastUpdate = time;

        double val = x + y + z - lastx - lasty - lastz;
        double speed = val.abs()/diff*5000;

        Scaffold.of(context).showSnackBar(SnackBar(content: Text(speed.toString())));
        if(x != lastx) {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("phone is SHOOK")));
          lastx = x;
        }
        //lastx = event.x;
        lasty = event.y;
        lastz = event.z;
      }
    });
    */
    ////////////////////////////////////////////////////////

    return Scaffold(
      body: new Container(
        child: new Stack(
          children: <Widget>[
            new Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(image: new AssetImage("assets/shape_matching/colored_talltrees.png"),fit: BoxFit.cover),
              ),
            ),
            new Positioned(
              left: screenWidth/2 - 264/2,
              top: screenHeight/12,
              child: Opacity(opacity: textOpacity,  child: Image(image: AssetImage("assets/shape_matching/Good_Job.png")),)
            ),
            new Positioned(
              child: new Stack(
                //alignment: FractionalOffset.center,
                //overflow: Overflow.visible,
                children: stackChildren,
              )
              ,
              //left: screenWidth/2,
              //top: screenHeight/2,
              //bottom: 50
            ),
            new Positioned(
              left: widget.offset1.dx,
                top: widget.offset1.dy - widget.height + 20,
              child: Draggable(
                data: "red",
                  child: box, feedback: box,
              childWhenDragging: new Opacity(opacity: 0.0, child: box),
              onDraggableCanceled: (v,o) {
                    setState(() { widget.offset1 = Offset(o.dx, o.dy + widget.height - 20);});
              },
              ),
            ),
            new Positioned(
              //left: 300,
              //top: 300,
              left: widget.offset2.dx,
              top: widget.offset2.dy - widget.height + 20,
              child: Draggable(
                data: "blue",
                child: box2, feedback: box2,
                childWhenDragging: new Opacity(opacity: 0.0, child: box2),
                onDraggableCanceled: (v,o) {
                  setState(() => widget.offset2 = Offset(o.dx, o.dy + widget.height - 20));
                },
              ),
            ),
            new Positioned(
              //left: 300,
              //top: 300,
              left: widget.offset3.dx,
              top: widget.offset3.dy - widget.height + 20,
              child: Draggable(
                data: "green",
                child: box3, feedback: box3,
                childWhenDragging: new Opacity(opacity: 0.0, child: box3),
                onDraggableCanceled: (v,o) {
                  setState(() => widget.offset3 = Offset(o.dx, o.dy + widget.height - 20));
                },
              ),
            ),
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
              acceptedData = data;
              if(data == answerData) {
                animationInit = false;
                sparklesAnimationController.forward(from: 0.0);

                player.play(correctAudioPath);
                //Scaffold.of(context).showSnackBar(SnackBar(content: Text("good job!!")));

                var rng = new Random();
                var num = rng.nextInt(3);

                while (num == lastNum)
                  {
                    num = rng.nextInt(3);
                  }

                if(num == 1) {
                  answerData = "green";
                  target = greenTriangleWidget();
                }
                else if(num == 2) {
                  answerData = "blue";
                  target = blueSquareWidget();
                }
                else {
                  answerData = "red";
                  target = redSquareWidget();
                }
                lastNum = num;
                  //target = test2;
              }
              else {
                //Scaffold.of(context).showSnackBar(SnackBar(content: Text("try again.")));
              }
            },
          ),),
          ],
        ),
      ),
    );
  }
}