import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';

enum TileState { covered, flipped, revealed }

class MemoryGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory App',
      home: Board(),
    );
  }
}

class Board extends StatefulWidget {
  @override
  BoardState createState() => BoardState();
}

class BoardState extends State<Board> {
  String appName = "Memory Game";
  final int rows = 5;
  final int cols = 4;
  int remainingCards;
  int completedGames = 0;
  List<List<TileState>> uiState;
  List<List<bool>> tiles;
  List<int> animalCount;
  List<List<String>> animals;
  bool correct;
  int animalsFound = 0;
  bool wonGame;
  bool allMatchesNotFound;
  Timer timer;
  Stopwatch stopwatch = Stopwatch();
  String match1;
  String match2;
  int prevX;
  int prevY;
  int count;
  int totalCards;
  int tapCount = 0;
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void resetBoard() {
    totalCards = rows * cols;
    remainingCards = totalCards;
    correct = false;
    wonGame = false;
    allMatchesNotFound = true;
    stopwatch.reset();
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {});
    });
    uiState = new List<List<TileState>>.generate(rows, (row) {
      return new List<TileState>.filled(cols, TileState.covered);
    });

    tiles = new List<List<bool>>.generate(rows, (row) {
      return new List<bool>.filled(cols, false);
    });

    animalCount = new List<int>.filled((totalCards / 2).round(), 2);
    animals = new List<List<String>>.generate(rows, (row) {
      return new List<String>.filled(totalCards, "animal");
    });
    Random random = Random();
    int dealtCards = totalCards;
    count = 0;
    while (dealtCards > 0) {
      int pos = random.nextInt(totalCards + 5);
      int row = pos ~/ rows;
      int col = pos % cols;
      int i = random.nextInt((totalCards / 2).round());
      //print("animalCount[$i]:");
      //print(animalCount[i]);
      //animalCount.toString();
      //print("tiles[$row][$col]:");
      //print(tiles[row][col]);
      //print("TrueCount: $trueCount");
      //print("dealtCards: $dealtCards");
      if (animalCount[i] > 0) {
        if (tiles[row][col] == false) {
          tiles[row][col] = true;
          if (i == 0) {
            animals[row][col] = "pig";
          } else if (i == 1) {
            animals[row][col] = "monkey";
          } else if (i == 2) {
            animals[row][col] = "penguin";
          } else if (i == 3) {
            animals[row][col] = "snake";
          } else if (i == 4) {
            animals[row][col] = "rabbit";
          } else if (i == 5) {
            animals[row][col] = "parrot";
          } else if (i == 6) {
            animals[row][col] = "panda";
          } else if (i == 7) {
            animals[row][col] = "hippo";
          } else if (i == 8) {
            animals[row][col] = "elephant";
          } else if (i == 9) {
            animals[row][col] = "giraffe";
          }
          animalCount[i]--;
          //print("If");
          dealtCards--;
          //print("tiles[$row][$col]:");
          //print(tiles[row][col]);
        }
      }
    }
    for (int j = 0; j < rows; j++) {
      for (int k = 0; k < cols; k++) {
        print("Tiles[$j][$k]");
        print(tiles[j][k]);
        print("animals[$j][$k]:");
        print(animals[j][k]);
      }
    }
  }

  @override
  void initState() {
    resetBoard();
    super.initState();
  }

  Widget buildBoard() {
    List<Row> boardRow = <Row>[];

    for (int y = 0; y < rows; y++) {
      List<Widget> rowChildren = <Widget>[];
      for (int x = 0; x < cols; x++) {
        Future<String> flipACard() {
          return new Future<String>.delayed(new Duration(milliseconds: 500),
              () {
            flipCard(x, y);
            flipCard(prevX, prevY);
            return "Incorrect Match";
          });
        }

        TileState state = uiState[y][x];
        rowChildren.add(GestureDetector(
          onTap: () {
            if (((x == prevX) && (y == prevY))) {
              if (count == 0) {
                flipCard(x, y);
              }
              if (count == 1) {
                flipACard().then((value) {}).catchError((error) {
                  print('Error');
                });
              }
            } else {
              flipCard(x, y);
              print(animals[y][x]);
              if (count == 0) {
                prevX = x;
                prevY = y;
              }
              if (count == 1) {
                if (checkMatches(x, y, prevX, prevY)) {
                  animalsFound++;
                  remainingCards = remainingCards - 2;
                } else {
                  //sleep(new Duration(seconds: 1));
                  flipACard().then((value) {}).catchError((error) {
                    print('Error');
                  });
//                  flipCard(x,y);
//                  flipCard(prevX, prevY);
                }
              }

              count++;
              if (count == 2) {
                count = 0;
              }
              if (remainingCards <= 0) {
                completedGames++;
                resetBoard();
              }
            }
          },
          child: Listener(
              child: CoveredCardTile(
            revealed: state == TileState.flipped,
            posX: x,
            posY: y,
            anim: animals[y][x],
          )),
        ));
        /*if (state == TileState.covered) {
        } else {
          rowChildren.add(OpenCardTile(
            state: state,
          ));
        }*/
      }
      boardRow.add(Row(
        children: rowChildren,
        mainAxisAlignment: MainAxisAlignment.center,
        key: ValueKey<int>(y),
      ));
    }
    return Container(
      color: Colors.blue,
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: boardRow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int timeElapsed = stopwatch.elapsedMilliseconds ~/ 1000;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
          centerTitle: true,
          title: Text('Memory Game'),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(45.0),
              child: Row(children: <Widget>[
                FlatButton(
                  child: Text(
                    'Reset Game',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => resetBoard(),
                ),
                Container(
                  height: 40.0,
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                        text: wonGame
                            ? "You've Won! $timeElapsed seconds"
                            : allMatchesNotFound
                                ? "Matches made: $animalsFound Cards Left: $remainingCards Score: $completedGames"
                                : "You've Lost! $timeElapsed seconds"),
                  ),
                ),
              ]))),
      body: Container(
        color: Colors.yellow,
        child: Center(
          child: buildBoard(),
        ),
      ),
    );
  }

  void flipCard(int x, int y) {
    //should also take a bool to check whether cards are already matched
    if (!onBoard(x, y)) return;
    setState(() {
      if (uiState[y][x] == TileState.covered) {
        uiState[y][x] = TileState.flipped;
      } else {
        uiState[y][x] = TileState.covered;
      }
    });
  }

  bool checkMatches(int x, int y, int x2, int y2) {
    if (!onBoard(x, y)) return false;
    if (x == x2 && y == y2) return false;
    if (animals[y][x] == animals[y2][x2]) {
      print("True");
      print(animals[y][x]);
      print(animals[y2][x2]);
      return true;
    }
    return false;
  }

  bool onBoard(int x, int y) => x >= 0 && x < cols && y >= 0 && y < rows;
}

Widget buildTile(Widget child) {
  return Container(
    padding: EdgeInsets.all(1.0),
    height: 100.0,
    width: 75.0,
    color: Colors.yellow,
    margin: EdgeInsets.all(2.0),
    child: child,
  );
}

Widget buildInnerTile(Widget child, BoxDecoration image) {
  return Container(
    padding: EdgeInsets.all(1.0),
    margin: EdgeInsets.all(2.0),
    height: 90.0,
    width: 65.0,
    child: child,
    decoration: image,
  );
}

class CoveredCardTile extends StatelessWidget {
  final bool revealed;
  final int posX;
  final int posY;
  final String anim;

  CoveredCardTile({this.revealed, this.posX, this.posY, this.anim});

  @override
  Widget build(BuildContext context) {
    Widget text;
    if (revealed) {
      text = buildInnerTile(
        RichText(
          text: TextSpan(
            text: "$anim",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/animals/$anim.png'),
            alignment: Alignment.bottomCenter,
          ),
        ),
      );
    }

    Widget innerTile = Container(
      padding: EdgeInsets.all(1.0),
      margin: EdgeInsets.all(2.0),
      height: 90.0,
      width: 65.0,
      color: Colors.yellowAccent,
      child: text,
    );

    return buildTile(innerTile);
  }
}
