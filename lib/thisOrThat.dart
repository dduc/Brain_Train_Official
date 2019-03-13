import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(ThisOrThat());

class ThisOrThat extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'This or That',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget{
  @override
  GamePageState createState() => new GamePageState();
}

class GamePageState extends State<GamePage>{
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
  bool dragOverTarget = false;
  List<String> cards = new List();
  List<Card> gameCards = new List();
  int cardCount = 0;
  int cardCorrect = 0;
  bool correct = false;
  int randCorrect = 0;
  int randWrong = 0;
  int rand = 0;
  int coinFlip = 0;
  Random random = Random();

  @override
  void initState(){
    resetGame();
    super.initState();

  }

  /*Function is called when user taps the Reset Game button and when the
  * game board is initialized*/
  void resetGame(){
    setState(() {
      cardCorrect = 0;
      cardCount = 0;
      correct = false;
      cards.add('cow');
      cards.add("cherry");
      cards.add("chicken");
      cards.add("car");
      cards.add("dog");
      cards.add("duck");
      cards.add("moon");
      cards.add("tree");
      cards.add("plane");
      cards.add("rock");
      for(cardCount = 0; cardCount < 10; cardCount++){
        gameCards.add(buildCard(cards[cardCount]));
      }
      cardCount = 0;
    });
    coinFlip = random.nextInt(2);
    rand = random.nextInt(10);
    randCorrect = random.nextInt(10);
    randWrong = random.nextInt(10);
    while(randCorrect == randWrong){
      randWrong = random.nextInt(10);
    }
    if(coinFlip == 0){
      rand = randCorrect;
    } else {
      rand = randWrong;
    }

  }
  /* This will build out the main game scene*/
  @override
  Widget build(BuildContext context){
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        centerTitle: true,
        title: Text('This or That'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: Row(children: <Widget>[
            /* Button for resetting the game */
            FlatButton(
              child: Text('Reset Game', style: TextStyle(color: Colors.white),
              ),
              onPressed: () => resetGame(),
            ),
            Container(
              height: 40.0,
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(
                    text: "Cards: $cardCorrect"
                ),
              ),
            )
          ],

          ),
        ),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              /* Calls the dragTargetMatch() function to check for a match */
              dragTargetMatch(),
              Text(cards[randCorrect]),
              /* Creates a draggable widget with the gameCard as a child */
              Draggable(
                maxSimultaneousDrags: 1,
                axis: Axis.vertical,
                data: cards[rand],
                child: gameCards[rand],
                feedback: gameCards[rand],
                childWhenDragging: Container(),
              ),
              Text(cards[randWrong]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  /* Calls the dragTargetNotMatch() function to check whether there is no match */
                  dragTargetNotMatch(),
                ],
              ),
            ],
          ),
        ),

      ),
    );
  }

/* Checks if a draggable is a match */
  Widget dragTargetMatch(){
    return Container(
      width: 200.0,
      height: 100.0,
      color: Colors.green,
      child: DragTarget(
        builder:
            (context, List<String> candidateData, rejectedData){
          return Center(
              child: Text("Correct", style: TextStyle(color: Colors.white),));
        },
        onWillAccept: (data){
          if(data == cards[randCorrect]){
            return true;
          } else {
            return false;
          }
        },
        onAccept: (data){
          if(data == cards[randCorrect]){
            setState(() {
              cardCorrect++;
              coinFlip = random.nextInt(2);
              randCorrect = random.nextInt(10);
              while(randCorrect == randWrong){
                randWrong = random.nextInt(10);
              }
              if(coinFlip == 0){
                rand = randCorrect;
              } else {
                rand = randWrong;
              }
            });
            //scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Correct")));
            print("true");
          } else {
            scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Wrong")));
          }
        },
      ),
    );
  }
  Widget dragTargetNotMatch(){
    return Container(
      width: 200.0,
      height: 100.0,
      color: Colors.red,
      child: DragTarget(
        builder:
            (context, List<String> candidateData, rejectedData){
          return Center(
              child: Text("Wrong", style: TextStyle(color: Colors.white),));
        },
        onWillAccept: (data){
          if(data == cards[randWrong]){
            return true;
          } else {
            return false;
          }
        },
        onAccept: (data){
          if(data == cards[randWrong]){
            setState(() {
              cardCorrect++;
              coinFlip = random.nextInt(2);
              randCorrect = random.nextInt(10);
              while(randCorrect == randWrong){
                randWrong = random.nextInt(10);
              }
              if(coinFlip == 0){
                rand = randCorrect;
              } else {
                rand = randWrong;
              }
            });
            //scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Correct")));
            print("true");
          } else {
            scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Wrong")));
          }
        },
      ),
    );
  }

  /*This function will create cards for the game*/
  Card buildCard(String cName) {
    return Card(
      margin: EdgeInsets.only(left: 120.0, right: 120.0, top: 20.0, bottom: 20.0),
      color: Colors.yellow,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Image(image: AssetImage('assets/this_or_that/$cName.png')),
            Text('$cName'),
          ],
        ),
      ),
    );
  }

}
