import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

//get relevant user info
import 'package:brain_train_official/main.dart' as login;

// BT API related Imports
import 'package:http/http.dart' as http;

//get child tracking info
import 'package:brain_train_official/profile.dart' as profile;

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

class SoundManager {
  AudioPlayer audioPlayer = new AudioPlayer();

  Future playLocal(localFileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = new File("${dir.path}/$localFileName");
    if (!(await file.exists())) {
      final soundData = await rootBundle.load("assets/sounds/$localFileName");
      final bytes = soundData.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    }
    await audioPlayer.play(file.path, isLocal: true);
  }

  Future stop() async {
    await audioPlayer.stop();
  }
}

//function to insert game session
void insLanguageGameInfo(String gname,int m,var s, var e,String cid) async {
  print("inserting game info...");
  String stars = "";
  print("total matches");
  print(m);

  //Star logic (for now)
  if (m > 24) {
    print("3 stars");
    stars = "3";
  }

  if (m <= 24 && m > 12) {
    print("2 stars");
    stars = "2";
  }

  if (m <= 12 && m >= 1) {
    print("1 star");
    stars = "1";
  }

  if (m == 0) {
    print("0 stars");
    stars = "0";
  }

  Map<String, dynamic> playlang = {
    'stars': stars,
    'game_name': gname,
    'start_time': s.toString(),
    'end_time': e.toString(),
    'Player_id': cid
  };

  String pllan = json.encode(playlang);

  final response = await http.post(
      'https://braintrainapi.com/btapi/player_languages',
      headers: {"Content-Type": "application/json"}, body: pllan);
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
  int randPrevious = 0;
  int rand = 0;
  int coinFlip = 0;
  int totalCards = 36;
  Random random = Random();
  String cardText;

  //get child ID for later insert
  String cid = profile.activeChildID;

  //var for timer
  var start;

  String appName = "This or That";

  //score tracker for overall game session
  int match = 0;

  @override
  void initState(){
    resetGame();
    super.initState();

    //timer for how long child played
    start = DateTime.now();
  }

  @override
  dispose(){
    super.dispose();

    //Insert info to DB for game session
    var end = DateTime.now();
    insLanguageGameInfo(appName,match,start,end,cid);

    //cancel animation controller and sound.
    soundManager.stop();
    audioPlayer.stop();
  }
  /*Function is called when user taps the Reset Game button and when the
  * game board is initialized*/
  void resetGame(){
    setState(() {
      cardCorrect = 0;
      cardCount = 0;
      correct = false;
      cards.add('ball');
      cards.add('book');
      cards.add('calculator');
      cards.add("car");
      cards.add("castle");
      cards.add("cherry");
      cards.add("chicken");
      cards.add("coin");
      cards.add("compass");
      cards.add("computer");
      cards.add('cow');
      cards.add("cup");
      cards.add("dog");
      cards.add("duck");
      cards.add("flashlight");
      cards.add("fork");
      cards.add("frog");
      cards.add("hammer");
      cards.add("house");
      cards.add("key");
      cards.add("microphone");
      cards.add("money");
      cards.add("moon");
      cards.add("mug");
      cards.add("paintbrush");
      cards.add("pan");
      cards.add("pencil");
      cards.add("phone");
      cards.add("saw");
      cards.add("tree");
      cards.add("plane");
      cards.add("rock");
      cards.add("spaceship");
      cards.add("spoon");
      cards.add("star");
      cards.add("toothbrush");
      for(cardCount = 0; cardCount < totalCards; cardCount++){
        gameCards.add(buildCard(cards[cardCount]));
      }
      cardCount = 0;
    });
    coinFlip = random.nextInt(2);
    rand = random.nextInt(totalCards);
    randCorrect = random.nextInt(totalCards);
    randWrong = random.nextInt(totalCards);
    randPrevious = rand;
    while(randCorrect == randWrong){
        randWrong = random.nextInt(totalCards);
    }
    if(coinFlip == 0){
      rand = randCorrect;
    } else {
      rand = randWrong;
    }

  }
  //create audio player for quick sounds and sound manager for
  //sounds that require more control (things like stop().
  AudioPlayer audioPlayer = new AudioPlayer();
  SoundManager soundManager = new SoundManager();
  //create audio cache for quick sounds
  AudioCache player = new AudioCache();
  static const correctAudioPath = "sounds/Completion.mp3";
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
              //Text(cards[randCorrect]),
              cardSound(cards[randCorrect]),
              /* Creates a draggable widget with the gameCard as a child */
              Draggable(
                maxSimultaneousDrags: 1,
                axis: Axis.vertical,
                data: cards[rand],
                child: gameCards[rand],
                feedback: gameCards[rand],
                childWhenDragging: Container(),
              ),
              //Text(cards[randWrong]),
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

  Widget cardSound(card){
     String cardText = card.toString();
     sleep(Duration(milliseconds: 500));
     //Future.delayed(const Duration(milliseconds: 3000), () {
       //setState(() {
         player.play("sounds/$cardText.mp3");
       //});
     //});
     return Text("$cardText");
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
              //child: Text("Correct", style: TextStyle(color: Colors.white),)
          );
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
            //increment global score tracker for correct cards
            //(this is for whole session, disregarding resetGame
            match++;

            setState(() {
              cardCorrect++;
              //play "Completion" sound effect
              player.play("sounds/correct.ogg");
              /*Future.delayed(const Duration(milliseconds: 500), () {
                player.play(correctAudioPath);
              });*/
              coinFlip = random.nextInt(2);
              randCorrect = random.nextInt(totalCards);
              while(randCorrect == randWrong){
                randWrong = random.nextInt(totalCards);
              }
              randPrevious = randCorrect;
              if(coinFlip == 0){
                rand = randCorrect;
              } else {
                rand = randWrong;
              }
            });
            //scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Correct")));
            print("true");
          } else {
            //scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Wrong")));
                player.play("sounds/wrong.ogg");
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
              //child: Text("Wrong", style: TextStyle(color: Colors.white),)
          );
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
              //play "Completion" sound effect
              player.play("sounds/correct.ogg");
              /*Future.delayed(const Duration(milliseconds: 500), () {
                player.play(correctAudioPath);
              });*/
              coinFlip = random.nextInt(2);
              randCorrect = random.nextInt(totalCards);
              while(randCorrect == randWrong){
                randWrong = random.nextInt(totalCards);
              }
              randPrevious = randCorrect;
              if(coinFlip == 0){
                rand = randCorrect;
              } else {
                rand = randWrong;
              }
            });
            //scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Correct")));
            print("true");
          } else {
            //scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Wrong")));
            setState(() {
              player.play("sounds/wrong.ogg");
            });
          }
        },
      ),
    );
  }

  /*This function will create cards for the game*/
  Card buildCard(String cName) {
    return Card(
      margin: EdgeInsets.only(left: 150.0, right: 150.0, top: 20.0, bottom: 20.0),
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
